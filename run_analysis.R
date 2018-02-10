# PROGRAM NAME  : run_analysis.R 
# DESCRIPTION   : For Coursera's JHU Getting & Cleaning Data Course Project 
# AUTHOR        : Alvinjohn Escoro
# DATE CREATED  : 20180210
#==========================================================================================================

#===== START OF THE PROGRAM =====#
getwd()

#### 1. DOWNLOAD & UNZIP THE DATASET ####

if(!file.exists("./data")){
  dir.create("./data")
}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile="./data/Dataset.zip", method="curl")

# Unzip dataset to /data directory
unzip(zipfile = "./data/Dataset.zip", exdir = "./data")


#### 2. MERGE THE TRAINING & THE TEST DATA TO CREATE ONE DATASET ####

# Read activity labels
activityLabels <- read.table('./data/UCI HAR Dataset/activity_labels.txt')
names(activityLabels) <- c('activityId', 'activityType')

# Read features vector
features <- read.table('./data/UCI HAR Dataset/features.txt')

# Read trainings table
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
names(x_train) <- features[, 2] 

y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
names(y_train) <- "activityId"

subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
names(subject_train) <- "subjectId"

# Read testing tables
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
names(x_test) <- features[, 2]

y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
names(y_test) <- "activityId"

subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
names(subject_test) <- "subjectId"


# Merge all data in one set 
train <- cbind(y_train, subject_train, x_train)
test <- cbind(y_test, subject_test, x_test)
allData <- rbind(train, test)


#### 3. EXTRACT ONLY THE MEASUREMENTS ON THE MEAN & SD FOR EACH MEASUREMENT ####

# Read column names
columnNames <- names(allData)

# Create vector for defining ID, mean & SD
mean_and_std <- ( grepl("activityId" , columnNames) | 
                  grepl("subjectId" , columnNames) | 
                  grepl("mean.." , columnNames) | 
                  grepl("std.." , columnNames))

allDataMeanStd <- allData[, mean_and_std == TRUE]


#### 4. USE DESCRIPTIVE ACTIVITY NAMES TO NAME THE ACTIVITIES IN THE DATASET ####

allDataMeanStd_w_ActivityNames <- merge(allDataMeanStd, activityLabels, by='activityId', all.x=TRUE)


#### 5. CREATE TIDY DATASET W/ THE MEAN OF EACH VARIABLE FOR EACH ACTIVITY & EACH SUBJECT ####

tidySet <- aggregate(. ~subjectId + activityType, allDataMeanStd_w_ActivityNames, mean)
tidySet <- tidySet[order(tidySet$subjectId, tidySet$activityId), ]

# Output in text file
write.table(tidySet, "tidy.txt", row.name=FALSE)

#===== END OF THE PROGRAM =====#
