# air-health-sws-airflow
Scientific workflow system for environmental health impact assessments using Apache Airflow.

## Table of Contents

* [Instruction to set up Airflow platform and related task on VM](#instruction-to-set-up-airflow-platform-and-related-task-on-vm)
* [Instructions written during development phase](#instructions-written-during-development-phase)
    + [Setting up Airflow in your machine](#setting-up-airflow-in-your-machine)
    + [Install new packages](#install-new-packages)
    + [Run R scripts via the command line](#run-r-scripts-via-the-command-line)

## Instruction to set up Airflow platform and related task on VM

See [Tasks and Server Setup](./TASKS_AND_SERVER_SETUP.md) document.

## Instructions written during development phase

### Setting up Airflow in your machine

See [README](./air-flow-local-test/README.md).

### Install new packages

Installation of new packages happens via the [`install.R`](./test_scripts/install.R) file. Simply add the new packages to the list, save the file and commit the changes. Finally run the file in Rstudio or via command line:

```bash
$: Rscript install.R
```

### Run R scripts via the command line

In order to be able to integrate all the R scripts in Apache Airflow, the scripts need to be executed via the command line. This is possible via the `optparse` R package, that let you create input arguments to your script. For an example on how that works, please have a look at the [`00_main.R`](./test_scripts/00_main.R).


Running all your script via the command line, is quite simple, just execute the following:

```bash
$: Rscript 00_main.R -h
```

This will print out the required arguments the script expects as inputs:

```bash
Usage: 00_main.R [options]


Options:
    -r INPUT-RASTER-FILE, --input-raster-file=INPUT-RASTER-FILE
        Raster file path (relative to R project file)

    -s INPUT-SHAPE-FILE, --input-shape-file=INPUT-SHAPE-FILE
        Shape file path (relative to R project file)

    -o OUTPUT-FOLDER, --output-folder=OUTPUT-FOLDER
        Output folder path (relative to R project file)

    -f OUTPUT-FILE, --output-file=OUTPUT-FILE
        Output file path (relative to R project file)

    -h, --help
        Show this help message and exit
```

Following the indication of the help instructions, the script can be run with:

```bash
$: Rscript 00_main.R \
    -r data_demo/air_pollution/GlobalGWRwUni_PM25_GL_201601_201612-RH35-NoNegs_AUS_20180618.tif \
    -s data_demo/spatial_boundaries/sa22016_case_studyV2.shp \
    -o output_data \
    -f output_shapefile
```

#### Cloudstor read/write

In order to read and write to Cloudstor you need to create an "app" password from within your cloudstor account, see [instructions here](https://support.aarnet.edu.au/hc/en-us/articles/236034707-How-do-I-manage-change-my-passwords-). Then have a look at [`00_main_cloudstor.R`](./test_scripts/00_main_cloudstor.R)
