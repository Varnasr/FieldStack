
# CONTRIBUTING to FieldStack

Thank you for your interest in contributing! This project is open to improvements from researchers, MEL professionals, and developers.

---

## 📦 Setup Instructions

1. Clone the repo:
   ```
   git clone https://github.com/Varnasr/FieldStack.git
   ```

2. Open the project in RStudio

3. Install required packages:
   ```R
   install.packages(c("tidyverse", "sf", "testthat", "flexdashboard", "readxl"))
   ```

---

## 🧪 Testing

Test scripts live in `tests/`. Run all tests with:
```R
library(testthat)
test_dir("tests")
```

---

## 📄 Contribution Guidelines

- Fork and create a branch for your edits
- Add clear comments and minimal examples
- Document new functions in README if relevant
- Submit a pull request with a brief description

---

We especially welcome:
- Localised notebooks for India/South Asia context
- Additional visualisation or dashboard tools
- Translations, data ethics guidance, or mix-methods integrations
