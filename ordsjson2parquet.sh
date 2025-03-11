#!/bin/bash

# -----------------------------------------------------------------------------
# Convert Oracle Database ORDS JSON exports to Parquet files
# Author: William Gacquer
# GitHub: https://github.com/citron/ordsjson2parquet
# License: MIT
# Disclaimer: This script is provided "as is" without warranty of any kind.
# Use at your own risk. The author is not responsible for any damages or data loss.
# -----------------------------------------------------------------------------

# Check if at least one file was provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 file1.json [file2.json ...]"
    exit 1
fi

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "Python 3 is not installed. Please install Python 3."
    exit 1
fi

# Check and install Python dependencies if needed
if ! python3 -c "import pandas, pyarrow"; then
    echo "Installing Python dependencies..."
    python3 -m pip install pandas pyarrow
fi

# Conversion function
conversion_python() {
    local json_file="$1"
    local parquet_file="${json_file%.json}.parquet"

    python3 -c "
import json
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq

with open('$json_file', 'r') as f:
    data = json.load(f)

items = data.get('results', [{}])[0].get('items', [])

if not items:
    print(f'No data found in $json_file')
else:
    df = pd.DataFrame(items)
    table = pa.Table.from_pandas(df)
    pq.write_table(table, '$parquet_file')
    print(f'Conversion completed: $parquet_file')
"
}

# Process each file
for file in "$@"; do
    if [ -f "$file" ]; then
        echo "Converting $file..."
        conversion_python "$file"
    else
        echo "File $file does not exist."
    fi
done
