
README
-------

This repository contains the submission for the Getting and Cleaning Data Course Project.
It includes the following files:
- run_analysis.R           : A script that downloads and extracts the UCI HAR dataset, extracts
                             the mean and std of each measurement type for both train and test
                             data (merged) and then creates a tidy summary by activity type X subject.
- CodeBook.docx            : A code book describing the variables in the script
- UCI_HAR_tidy_dataset.txt : The tidy dataset, saved as a txt file with write.table
                             (can be read with read.table to recreate the dataset)
                   
