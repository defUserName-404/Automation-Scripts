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

# Function to convert Jupyter notebook to HTML
convert_to_html() {
    jupyter nbconvert --to html "$1"
}

# Function to convert HTML to PDF
convert_to_pdf() {
    wkhtmltopdf "$1" "$2"
}

# Process command line arguments
output_pdf="Book.pdf"
notebooks=()
delete_all_after=false

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

# Convert each notebook to HTML and then to PDF
html_files=()
for notebook in "${notebooks[@]}"; do
    html_file="${notebook%.ipynb}.html"
    pdf_file="${notebook%.ipynb}.pdf"
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
if [ "$delete_all_after" = true ]; then
    for html_file in "${notebooks[@]}"; do
        rm "${html_file%.ipynb}.html"
        rm "${html_file%.ipynb}.pdf"
    done
fi

echo "Conversion complete. Output PDF: $output_pdf"
