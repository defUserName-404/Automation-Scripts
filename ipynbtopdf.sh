#!/bin/bash

# Function to display help message
display_help() {
    echo "Usage: $0 [OPTIONS] [NOTEBOOKS]"
    echo "Convert one or more Jupyter notebooks to a single PDF file."
    echo
    echo "Options:"
    echo "  -o, --output FILE   Specify the output PDF file name (default: Book.pdf)"
    echo "  --delete-all-after  Delete intermediate HTML and PDF files after conversion"
    echo "  -h, --help           Display this help message"
    echo
    echo "Examples:"
    echo "  $0 notebook.ipynb -o output.pdf"
    echo "  $0 notebook1.ipynb notebook2.ipynb --delete-all-after"
    echo
}

# Check if wkhtmltopdf, cpdf, and Jupyter are installed
if ! command -v wkhtmltopdf &>/dev/null || ! command -v cpdf &>/dev/null || ! command -v jupyter &>/dev/null; then
    echo "Please make sure wkhtmltopdf, cpdf, and Jupyter are installed."
    exit 1
fi

# Process command line arguments
output_pdf="Book.pdf"
notebooks=()
delete_all_after=false
default_margin="2mm 2mm 2mm 2mm"
margins=""

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -o|--output)
            output_pdf="$2"
            shift
            shift
            ;;
        --delete-all-after)
            delete_all_after=true
            shift
            ;;
		-m|--margin)
            margins="$2"
            shift
            shift
            ;;
        --margin-top)
            margin_top="$2"
            shift
            shift
            ;;
        --margin-right)
            margin_right="$2"
            shift
            shift
            ;;
        --margin-bottom)
            margin_bottom="$2"
            shift
            shift
            ;;
        --margin-left)
            margin_left="$2"
            shift
            shift
            ;;

        -h|--help)
          display_help
          exit 0
          ;;
        *)
            notebooks+=("$1")
            shift
            ;;
    esac
done

# Check if any notebooks were specified
if [ ${#notebooks[@]} -eq 0 ]; then
    echo "No input Jupyter notebooks specified."
    exit 1
fi

# Check if the output PDF file already exists
if [ -e "$output_pdf" ]; then
    while true; do
        read -p "The file $output_pdf already exists. Do you want to overwrite it? (yes/no): " response
        case $response in
            [Yy]*)
                break
                ;;
            [Nn]*)
                i=1
                original_output_pdf="$output_pdf"
                while [ -e "$output_pdf" ]; do
                    output_pdf="${original_output_pdf%.pdf}($i).pdf"
                    i=$((i+1))
                done
                echo "Renaming the file to $output_pdf."
                break
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
fi

# If margin values are not provided, use default margins
if [ -z "$margins" ]; then
    margins="$default_margin"
fi

# Extract margin values
margin_values=($margins)
if [ "${#margin_values[@]}" -eq 4 ]; then
    margin_top="${margin_values[0]}"
    margin_right="${margin_values[1]}"
    margin_bottom="${margin_values[2]}"
    margin_left="${margin_values[3]}"
else
    echo "Error: Specify all four margin values (top right bottom left) using -m or --margin."
    exit 1
fi

# Function to convert Jupyter notebook to HTML
convert_to_html() {
    jupyter nbconvert --to html "$1"
}

# Function to convert HTML to PDF
convert_to_pdf() {
    wkhtmltopdf --margin-top "$margin_top" --margin-right "$margin_right" --margin-bottom "$margin_bottom" --margin-left "$margin_left" "$1" "$2"
}

# Convert each notebook to HTML and then to PDF
html_files=()
for notebook in "${notebooks[@]}"; do
    html_file="${notebook%.ipynb}.html"
    pdf_file="${notebook%.ipynb}_generated.pdf"
    convert_to_html "$notebook"
    convert_to_pdf "$html_file" "$pdf_file"
    html_files+=("$pdf_file")
done

# Merge the PDFs using cpdf
if [ ${#html_files[@]} -gt 1 ]; then
    cpdf cat "${html_files[@]}" -o "$output_pdf"
else
    mv "${html_files[0]}" "$output_pdf"
fi

# Clean up intermediate files if --delete-all-after is specified
clean_up() {
	if [ "$delete_all_after" = true ]; then
		for html_file in "${notebooks[@]}"; do
			html_filename="${html_file%.ipynb}.html"
			pdf_filename="${html_file%.ipynb}_generated.pdf"
			if [ -e "$html_filename" ]; then
				rm "$html_filename"
			fi
			if [ -e "$pdf_filename" ]; then
				rm "$pdf_filename"
			fi
		done
	fi
}

# Prompt the user to delete the generated files
if [ "$delete_all_after" = false ]; then
    read -p "Do you want to delete the generated HTML and PDF files? (yes/no): " delete_response
    case $delete_response in
        [Yy]*)
			delete_all_after=true
            clean_up
			;;
        *)
            echo "Generated files were not deleted."
            ;;
    esac
else
	clean_up
fi

echo
echo
echo "Conversion complete. Output PDF: $output_pdf"
