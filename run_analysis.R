## Script for tidying up data from Galaxy S accelerometers. Selects only mean 
## and std from training and test datasets and merges them into one dataset
## with descriptive labels

## Loads relevant packages
library(dplyr)

## Defines global variables for the url, the directory in which to save the
## files, the repository directory and the relevant filenames in the ZIP
extractedDir = "UCI HAR Dataset/"
ZIPfilename <- "getdata_projectfiles_UCI HAR Dataset.zip"
outputFile <- "G:/Documents/coursera/getting_cleaning_data/repo/UCI_HAR_tidy_dataset.txt"
labelsFile <- "activity_labels.txt"
featuresFile <- "features.txt"
trainSubjectsFile <- "train/subject_train.txt"
testSubjectsFile <- "test/subject_test.txt"
trainLabelFile <- "train/y_train.txt"
testLabelFile <- "test/y_test.txt"
trainDataFile <- "train/X_train.txt"
testDataFile <- "test/X_test.txt"


## Verifies that the data exists either as a ZIP or as an open directory in the current working dir
## If it exists only as a ZIP, extracts it
if (!file.exists(extractedDir)) {
  if (file.exists(ZIPfilename)) {
    unzip(destZIP)
  } else {
    stop("Could not find data in working dir")
  }
}

## Loads the training and test sets

## Loads the general files with the feature names and activity labels
activityLabels <- read.table(paste(extractedDir, labelsFile, sep=""), 
                             stringsAsFactors=FALSE)
features <- read.table(paste(extractedDir, featuresFile, sep=""), 
                       stringsAsFactors=FALSE)

## Loads training set and test set information
trainData <- read.table(paste(extractedDir, trainDataFile, sep=""))
trainSubjects <- read.table(paste(extractedDir, trainSubjectsFile, sep=""))
trainLabels <- read.table(paste(extractedDir, trainLabelFile, sep=""), 
  stringsAsFactors=FALSE)

testData <- read.table(paste(extractedDir, testDataFile, sep=""))
testSubjects <- read.table(paste(extractedDir, testSubjectsFile, sep=""))
testLabels <- read.table(paste(extractedDir, testLabelFile, sep=""), 
  stringsAsFactors=FALSE)


## Merges training and tests into one dataset (after removing the irrelevant
## columns from each). Since these are different subjects - simple concatenation
## Also adds columns for subject and activitiy label and whether this is train
## or test
mean_cols <- grep("mean()", features[,2], fixed=TRUE)
std_cols <- grep("std()", features[,2], fixed=TRUE)
allSubjects <- rbind(trainSubjects, testSubjects)
allLabels <- rbind(trainLabels, testLabels)
sampleType <- c(rep("train", nrow(trainSubjects)), 
                rep("test", nrow(testSubjects)))
mergedData <- cbind(allSubjects, allLabels, sampleType, 
  rbind(trainData[,c(mean_cols, std_cols)], testData[,c(mean_cols, std_cols)]))

## Sets the names of mergedData to be based on the feature names and replaces
## the activity label numbers with label names. Also makes the names a bit
## nicer (without parentheses and dashes)
featuresClean <- gsub("-", "", gsub("()", "", 
              gsub("std", "Std", gsub("mean", "Mean", features[,2])), fixed=TRUE))
names(mergedData) <- c("subject", "activity", "sampleType", 
                       featuresClean[mean_cols], featuresClean[std_cols])
mergedData[,2] <- activityLabels[mergedData[,2],2]
  
## Groups by activity and subject and averages each variable
dataSummary <- mergedData %>% group_by(activity, subject) %>% 
  summarise_each(funs(mean), 4:ncol(mergedData))

## Saves the data to the repo directory
write.table(dataSummary, outputFile, row.name=FALSE)