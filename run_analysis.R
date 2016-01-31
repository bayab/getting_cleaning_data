## Script for tidying up data from Galaxy S accelerometers. Selects only mean 
## and std from training and test datasets and merges them into one dataset
## with descriptive labels

## Loads relevant packages
library(dplyr)

## Defines global variables for the url, the directory in which to save the
## files, the repository directory and the relevant filenames in the ZIP
dataURL <- 
  "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dataDir <- "G:/Documents/coursera/getting_cleaning_data/"
ZIPfilename <- "UCI_HAR_Dataset.zip"
outputFile <- "G:/Documents/coursera/getting_cleaning_data/repo/UCI_HAR_tidy_dataset.txt"
labelsFile <- "activity_labels.txt"
featuresFile <- "features.txt"
subjectsPrefix <- "subject_"
dataPrefix <- "X_"
dataLabelsPrefix <- "y_"
testSuffix <- "test.txt"
trainSuffix <- "train.txt"

  
## Loads the training and test sets

## Downloads and extracts the ZIP
setwd(dataDir)
destZIP <- paste(dataDir,ZIPfilename, sep="")
download.file(dataURL, destZIP)
extractedFiles <- unzip(destZIP)

## Loads the general files with the feature names and activity labels
activityLabels <- read.table(extractedFiles[grep(labelsFile, extractedFiles)], 
                             stringsAsFactors=FALSE)
features <- read.table(extractedFiles[grep(featuresFile, extractedFiles)], 
                       stringsAsFactors=FALSE)

## Loads training set and test set information
trainData <- read.table(extractedFiles[
  grep(paste("/", dataPrefix, trainSuffix, sep=""), extractedFiles)])
trainSubjects <- read.table(extractedFiles[
  grep(paste(subjectsPrefix, trainSuffix, sep=""), extractedFiles)])
trainLabels <- read.table(extractedFiles[
  grep(paste("/", dataLabelsPrefix, trainSuffix, sep=""), extractedFiles)], 
  stringsAsFactors=FALSE)

testData <- read.table(extractedFiles[
  grep(paste("/", dataPrefix, testSuffix, sep=""), extractedFiles)])
testSubjects <- read.table(extractedFiles[
  grep(paste(subjectsPrefix, testSuffix, sep=""), extractedFiles)])
testLabels <- read.table(extractedFiles[
  grep(paste("/", dataLabelsPrefix, testSuffix, sep=""), extractedFiles)], 
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
write.table(dataSummary, outputFile)