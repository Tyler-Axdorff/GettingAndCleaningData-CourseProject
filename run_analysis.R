# run_analysis.r processing steps:
# 0. Ensure file has been downloaded, extract, and load raw data
# 1. Merge the training and the test sets
# 2. Filter to only measurements on the mean and standard deviation for each measurement. 
# 3. Add descriptive activity names to name the activities in the data set
# 4. Appropriately label the data set with descriptive activity names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Used in step 5, install with 'install.packages("plyr")' & 'install.packages("dplyr")
require (plyr)
require (dplyr)

# Directories variables
data_dir <- "./UCI\ HAR\ Dataset"
tests_dir <- paste(data_dir, "/test", sep="")
train_dir <- paste(data_dir, "/train", sep="")

# File variables
activity_labels_file <- paste(data_dir, "/activity_labels.txt", sep="")
features_file <- paste(data_dir, "/features.txt", sep="")
features_info_file <- paste(data_dir, "/features_info.txt", sep="")
x_tests_file <- paste(tests_dir, "/X_test.txt", sep="")
x_train_file <- paste(train_dir, "/X_train.txt", sep="")
y_tests_file <- paste(tests_dir, "/y_test.txt", sep="")
y_train_file <- paste(train_dir, "/y_train.txt", sep="")
subject_tests_file <- paste(tests_dir, "/subject_test.txt", sep="")
subject_train_file <- paste(train_dir, "/subject_train.txt", sep="")

##############################################
# Step 0. Downlaod, Extract, & Load raw data #
##############################################

# Download & extract zip if it doesn't exist
if (!file.exists(data_dir)) {
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl,destfile="./UCI HAR Dataset.zip",method="curl")
  unzip(zipfile="./UCI HAR Dataset.zip",exdir="./")
}

# Load in x data
x_tests <- read.table(x_tests_file, header=FALSE)
x_train <- read.table(x_train_file, header=FALSE)

# Load in y data
y_tests <- read.table(y_tests_file, header=FALSE)
y_train <- read.table(y_train_file, header=FALSE)

# Load in subject data
subject_tests <- read.table(subject_tests_file, header=FALSE)
subject_train <- read.table(subject_train_file, header=FALSE)

# Load in features & activity labels data
features <- read.table(features_file, header=FALSE)
activity_labels <- read.table(activity_labels_file, header=FALSE)

# Add proper column names for datasets
colnames(activity_labels) <- c('activityId','activityType')

colnames(subject_train) <- "subjectId"
colnames(x_train)       <- features[,2] 
colnames(y_train)       <- "activityId"

colnames(subject_tests) <- "subjectId"
colnames(x_tests)       <- features[,2] 
colnames(y_tests)       <- "activityId"

########################################
# Step 1. Merge train & test data sets #
########################################

# Create complete x dataset 
x_data <- rbind(x_train, x_tests)

# Create complete y dataset
y_data <- rbind(y_train, y_tests)

# Create complete subject dataset
subject_data <- rbind(subject_train, subject_tests)

################################################
# Step 2. Filter to only mean/std measurements #
################################################

# get only features with 'mean' or 'std'
mean_std_feature_mask <- grep("-(mean|std)\\(\\)", features[, 2])

# subset the desired columns
x_data <- x_data[, mean_std_feature_mask]

##########################################################
# Step 3. Add descriptive activity names to the data set #
##########################################################

# Add activity name to y_data
y_data[, 2] <- activity_labels[y_data[, 1], 2] 
# This works by using the ActivityId column from y_data (column 1) and using
#  it as an index into column 1 of activity_labels and pulling out column 2 (detailed activity name)

# Update column name for y_data now that its not just an Id
y_train <- rename(y_data, activityType = V2)
#colnames(y_train) <- c("activityId","activityType")

##########################################
# Step 4. Add descriptive variable names #
##########################################

# Merge all data sets together (i did this a little later than normal to minimize step 2/3 problems)
data <- cbind(x_data, y_data, subject_data)

# Clean up data names
names(data) <- gsub("^t", "time", names(data)) # Replace 't' with 'time'
names(data) <- gsub("^f", "frequency", names(data)) # Replace 'f' with 'frequency'
names(data) <- gsub("[Aa]cc", "Accelerometer", names(data)) # Replace 'Acc' or 'acc' with 'Accelerometer'
names(data) <- gsub("[Gg]yro", "Gyroscope", names(data)) # Replace 'Gyro' or 'gyro' with 'Gyroscope'
names(data) <- gsub("[Mm]ag", "Magnitude", names(data)) # Replace 'Mag' or 'mag' with 'Magnitude'
names(data) <- gsub("[Bb]ody[Bb]ody", "Body", names(data)) # Replace 'BodyBody' or 'bodybody' with 'Body'
names(data) <- gsub("gravity","Gravity", names(data)) # Replace 'gravity' with 'Gravity'

#################################################################################################
# Step 5. Create second, independent tidy data set with average of each variable, write to file #
#################################################################################################

# Aggregate the data, but subject & activity, using the mean function across the values
tidy_data <- aggregate(. ~subjectId + activityId, data, mean)

# Order the data by subjectId, then activityId
tidy_data <- tidy_data[ order(tidy_data$subjectId, tidy_data$activityId), ]

# Write out to tidy_data.txt file
write.table(tidy_data, file="tidy_data.txt", row.name=FALSE)
