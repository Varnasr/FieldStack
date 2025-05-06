# Data Flow Documentation

This file explains the typical flow of data through the InsightStack toolkit.

📊 ![InsightStack Flow Diagram](./docs/InsightStack_data_flow_diagram_clean.png)

---

## 🔄 Typical Workflow

1. **Raw Data Entry**
   - Source: XLSForms, field surveys, or CSV files
   - Tools: `survey_to_codebook/`, `data_validation/`

2. **Data Validation**
   - Scripts flag:
     - Missing values
     - Duplicates
     - Out-of-range values
   - Folder: `data_validation/`

3. **Variable Labeling**
   - Apply readable labels from a dictionary
   - Folder: `label_variables/`
   - Compatible across R, Python, and Stata

4. **Exploration & Analysis**
   - Summary stats, regressions, and model testing
   - Folder: `replication/`
   - Can use Stata, R, or Python

5. **Documentation**
   - Convert survey design into Markdown codebooks
   - Folder: `survey_to_codebook/`

6. **Archival & Replication**
   - Reusable scripts, testable results, and cleaned data
   - Folder: `replication/`, with output storage

---

Each folder in InsightStack corresponds to one or more of these steps — allowing any user to jump in, adapt, or expand the workflow for their own context.