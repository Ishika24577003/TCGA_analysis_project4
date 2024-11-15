import glob
import os
import pandas as pd
import tarfile

# Define the workflow
rule all:
    input: "results/expression_summary.tsv", "results/sample_metadata.tsv", "results/expression_plot.png"

rule ExtractGeneExpressionData:
    input: "tcga_data.tar.gz"
    output: "results/extracted_data/"
    run:
        # Extract the tar.gz file
        with tarfile.open(input[0], "r:gz") as tar:
            tar.extractall(path=output[0])

rule ProcessGeneExpression:
    input: glob_wildcards("results/extracted_data/*/*.tsv")
    output: "results/expression_summary.tsv"
    run:
        with open(output[0], 'w') as out_f:
            out_f.write("Sample_Name\tExpression_Value\n")  # Write header
            for input_file in input:
                sample_name = os.path.basename(os.path.dirname(input_file))
                df = pd.read_csv(input_file, sep='\t', header=None)

                # Extract expression value for a specific gene (e.g., "GENE_Y")
                gene_row = df[df[1] == "GENE_Y"]  # Change GENE_Y to your gene of interest
                if not gene_row.empty:
                    expression_value = gene_row.iloc[0, 6]  # Assuming TPM is in the 7th column
                    out_f.write(f"{sample_name}\t{expression_value}\n")

rule CreateSampleMetadata:
    input:
        expression_data = "results/expression_summary.tsv",
        sample_sheet = "gdc_sample_sheet.2024-09-27.tsv"
    output:
        "results/sample_metadata.tsv"
    run:
        df_expression = pd.read_csv(input.expression_data, sep='\t')
        df_metadata = pd.read_csv(input.sample_sheet, sep='\t')  # Adjust the filename as necessary
        # Merge the expression data with metadata
        df_merged = df_metadata.merge(df_expression, left_on='File ID', right_on='Sample_Name', how='inner')
        df_filtered = df_merged[df_merged['Sample Type'].isin(['Solid Tissue Normal', 'Primary Tumor'])]
        # Save the final metadata file
        df_filtered.to_csv(output[0], sep='\t', index=False)

rule GeneratePlot:
    input:
        "results/sample_metadata.tsv"
    output:
        "results/expression_plot.png"
    shell:
        "./generate_boxplot.py {input} {output}"
