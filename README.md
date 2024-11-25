# Training Random Forest Models with Python and SAS in SAS Viya Workbench

Welcome to this repository! If you're curious about how Python and SAS can work together in SAS Viya Workbench, you've come to the right place. Here, we'll explore how to train Random Forest models using three different approaches:

- Python’s `scikit-learn`
- The SAS Python API (`sasviya`)
- `PROC FOREST` in SAS

The dataset used in this project is provided in the `CUSTOMS.csv` file. It contains approximately 7000 rows and 21 variables, representing information about incoming packages in Europe. Each row corresponds to a unique package, identified by a distinct package ID. The dataset includes various characteristics of the packages, as well as a target variable, `Inspection`, which indicates whether a package should be flagged for inspection.

The goal is to show just how flexible and accessible SAS Viya Workbench can be, and how you can leverage SAS analytics, even if you’re not familiar with the SAS programming language.

## What You'll Find Here

I've created two notebooks to guide you through this journey.

- In the first notebook (`Python - sasviya and scikit-learn Random Forests.ipynb`), we use Python to train Random Forest models. We start with `scikit-learn`, a familiar library for most Python developers, and then transition to the SAS Python API (`sasviya`). You'll notice how similar the syntax is between these two methods, making it easy for Python developers to adopt SAS analytics without a steep learning curve.
- The second notebook (`SAS - Random Forest.sasnb`) focuses on training a Random Forest model directly in SAS using `PROC FOREST`. I'll also provide the corresponding code to run on the SAS Viya platform using SAS Studio, allowing you to compare the two approaches side by side. The key consideration is that `PROC FOREST` works with CAS data on the SAS Viya platform, so you’ll need to load your data into memory within a caslib, create a CAS session, and assign a libref to the caslib beforehand.

Training the models is just the beginning. Once you've built your Random Forest models, I'll walk you through how to register them with SAS Model Manager. This step is crucial for integrating your models into the SAS Viya platform, where you can monitor their performance, deploy them in production, and manage their lifecycle.

Whether you're a seasoned Python developer looking to expand your toolkit or a SAS user curious about Python, this project demonstrates how the two worlds can complement each other seamlessly!

## Usage Notes :heavy_exclamation_mark:

For the registration step, the SAS notebook uses the ID of the project created by the Jupyter notebook. It's recommended to run the Jupyter notebook first, unless you prefer using a specific project in SAS Model Manager. In that case, just use your chosen project ID in both notebooks to register the models! :blush:
