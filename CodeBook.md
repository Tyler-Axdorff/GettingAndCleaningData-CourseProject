# Processing Steps
### run_analysis.r processing step summary:
0. Ensure file has been downloaded, extract, and load raw data
1. Merge the training and the test sets
2. Filter to only measurements on the mean and standard deviation for each measurement. 
3. Add descriptive activity names to name the activities in the data set
4. Appropriately label the data set with descriptive activity names. 
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

### Step 0 - Download, extract, load data

Create Directory & File Variables
```R
data_dir <- "./UCI\ HAR\ Dataset"
tests_dir <- paste(data_dir, "/test", sep="")
train_dir <- paste(data_dir, "/train", sep="")
activity_labels_file <- paste(data_dir, "/activity_labels.txt", sep="")
features_file <- paste(data_dir, "/features.txt", sep="")
features_info_file <- paste(data_dir, "/features_info.txt", sep="")
x_tests_file <- paste(tests_dir, "/X_test.txt", sep="")
x_train_file <- paste(train_dir, "/X_train.txt", sep="")
y_tests_file <- paste(tests_dir, "/y_test.txt", sep="")
y_train_file <- paste(train_dir, "/y_train.txt", sep="")
subject_tests_file <- paste(tests_dir, "/subject_test.txt", sep="")
subject_train_file <- paste(train_dir, "/subject_train.txt", sep="")
```

Download & extract zip if it doesn't exist
```R
if (!file.exists(data_dir)) {
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl,destfile="./UCI HAR Dataset.zip",method="curl")
  unzip(zipfile="./UCI HAR Dataset.zip",exdir="./")
}
```

Load in data
```R
x_tests <- read.table(x_tests_file, header=FALSE)
...
```

### Step 1. Merge train & test data sets

Create complete x dataset 
```R
x_data <- rbind(x_train, x_tests)
```

Create complete y dataset
```R
y_data <- rbind(y_train, y_tests)
```

Create complete subject dataset
```R
subject_data <- rbind(subject_train, subject_tests)
```

### Step 2. Filter to only mean/std measurements

get only features with 'mean' or 'std'
```R
mean_std_feature_mask <- grep("-(mean|std)\\(\\)", features[, 2])
```

subset the desired columns
```R
x_data <- x_data[, mean_std_feature_mask]
```

### Step 3. Add descriptive activity names to the data set

Add activity name to y_data
```R
y_data[, 2] <- activity_labels[y_data[, 1], 2] 
```
This works by using the ActivityId column from y_data (column 1) and using it as an index into column 1 of activity_labels and pulling out column 2 (detailed activity name)

Update column name for y_data now that its not just an Id
```R
y_data <- rename(y_data, activityType = V2)
```

### Step 4. Add descriptive variable names

Merge all data sets together (i did this a little later than normal to minimize step 2/3 problems)
```R
data <- cbind(x_data, y_data, subject_data)
```

Clean up data names
```R
names(data) <- gsub("^t", "time", names(data)) # Replace 't' with 'time'
names(data) <- gsub("^f", "frequency", names(data)) # Replace 'f' with 'frequency'
names(data) <- gsub("[Aa]cc", "Accelerometer", names(data)) # Replace 'Acc' or 'acc' with 'Accelerometer'
names(data) <- gsub("[Gg]yro", "Gyroscope", names(data)) # Replace 'Gyro' or 'gyro' with 'Gyroscope'
names(data) <- gsub("[Mm]ag", "Magnitude", names(data)) # Replace 'Mag' or 'mag' with 'Magnitude'
names(data) <- gsub("[Bb]ody[Bb]ody", "Body", names(data)) # Replace 'BodyBody' or 'bodybody' with 'Body'
names(data) <- gsub("gravity","Gravity", names(data)) # Replace 'gravity' with 'Gravity'
names(data) <- gsub("\\()", "", names(data)) # Get rid of '()' after mean / std
names(data) <- gsub("std", "StandardDeviation", names(data)) # Replace 'std' with 'StandardDeviation'
```

### Step 5. Create second, independent tidy data set with average of each variable, write to file

Aggregate the data, but subject & activity, using the mean function across the values
```R
tidy_data <- aggregate(. ~subjectId + activityType, data, mean)
```

Order the data by subjectId, then activityType
```R
tidy_data <- tidy_data[ order(tidy_data$subjectId, tidy_data$activityType), ]
```

Get rid of redundant activityId (since we have activityType)
```R
tidy_data <- tidy_data[, !names(tidy_data) %in% c("activityId")]
```

Write out to tidy_data.txt file
```R
write.table(tidy_data, file="tidy_data.txt", row.name=FALSE)
```


# Tidy Data Output
### File description
Output is 'tidy_data.txt' which is a table file (spaces are separators) which contains 180 rows of 68 variables
180 rows are determined as aggregated as follows:
- Per subjectId (participant) = 1..30
- Per activityType (6 types) = laying, sitting, standing, walking, walking_downstairs, walking_upstairs 
Therefore 6 types * 30 participants = 180 rows

### Variable list (averaged data)
| Variable                                                  |
|-----------------------------------------------------------|
| subjectId                                                 |
| activityType                                              |
| timeBodyAccelerometer-mean-X                              |
| timeBodyAccelerometer-mean-Y                              |
| timeBodyAccelerometer-mean-Z                              |
| timeBodyAccelerometer-StandardDeviation-X                 |
| timeBodyAccelerometer-StandardDeviation-Y                 |
| timeBodyAccelerometer-StandardDeviation-Z                 |
| timeGravityAccelerometer-mean-X                           |
| timeGravityAccelerometer-mean-Y                           |
| timeGravityAccelerometer-mean-Z                           |
| timeGravityAccelerometer-StandardDeviation-X              |
| timeGravityAccelerometer-StandardDeviation-Y              |
| timeGravityAccelerometer-StandardDeviation-Z              |
| timeBodyAccelerometerJerk-mean-X                          |
| timeBodyAccelerometerJerk-mean-Y                          |
| timeBodyAccelerometerJerk-mean-Z                          |
| timeBodyAccelerometerJerk-StandardDeviation-X             |
| timeBodyAccelerometerJerk-StandardDeviation-Y             |
| timeBodyAccelerometerJerk-StandardDeviation-Z             |
| timeBodyGyroscope-mean-X                                  |
| timeBodyGyroscope-mean-Y                                  |
| timeBodyGyroscope-mean-Z                                  |
| timeBodyGyroscope-StandardDeviation-X                     |
| timeBodyGyroscope-StandardDeviation-Y                     |
| timeBodyGyroscope-StandardDeviation-Z                     |
| timeBodyGyroscopeJerk-mean-X                              |
| timeBodyGyroscopeJerk-mean-Y                              |
| timeBodyGyroscopeJerk-mean-Z                              |
| timeBodyGyroscopeJerk-StandardDeviation-X                 |
| timeBodyGyroscopeJerk-StandardDeviation-Y                 |
| timeBodyGyroscopeJerk-StandardDeviation-Z                 |
| timeBodyAccelerometerMagnitude-mean                       |
| timeBodyAccelerometerMagnitude-StandardDeviation          |
| timeGravityAccelerometerMagnitude-mean                    |
| timeGravityAccelerometerMagnitude-StandardDeviation       |
| timeBodyAccelerometerJerkMagnitude-mean                   |
| timeBodyAccelerometerJerkMagnitude-StandardDeviation      |
| timeBodyGyroscopeMagnitude-mean                           |
| timeBodyGyroscopeMagnitude-StandardDeviation              |
| timeBodyGyroscopeJerkMagnitude-mean                       |
| timeBodyGyroscopeJerkMagnitude-StandardDeviation          |
| frequencyBodyAccelerometer-mean-X                         |
| frequencyBodyAccelerometer-mean-Y                         |
| frequencyBodyAccelerometer-mean-Z                         |
| frequencyBodyAccelerometer-StandardDeviation-X            |
| frequencyBodyAccelerometer-StandardDeviation-Y            |
| frequencyBodyAccelerometer-StandardDeviation-Z            |
| frequencyBodyAccelerometerJerk-mean-X                     |
| frequencyBodyAccelerometerJerk-mean-Y                     |
| frequencyBodyAccelerometerJerk-mean-Z                     |
| frequencyBodyAccelerometerJerk-StandardDeviation-X        |
| frequencyBodyAccelerometerJerk-StandardDeviation-Y        |
| frequencyBodyAccelerometerJerk-StandardDeviation-Z        |
| frequencyBodyGyroscope-mean-X                             |
| frequencyBodyGyroscope-mean-Y                             |
| frequencyBodyGyroscope-mean-Z                             |
| frequencyBodyGyroscope-StandardDeviation-X                |
| frequencyBodyGyroscope-StandardDeviation-Y                |
| frequencyBodyGyroscope-StandardDeviation-Z                |
| frequencyBodyAccelerometerMagnitude-mean                  |
| frequencyBodyAccelerometerMagnitude-StandardDeviation     |
| frequencyBodyAccelerometerJerkMagnitude-mean              |
| frequencyBodyAccelerometerJerkMagnitude-StandardDeviation |
| frequencyBodyGyroscopeMagnitude-mean                      |
| frequencyBodyGyroscopeMagnitude-StandardDeviation         |
| frequencyBodyGyroscopeJerkMagnitude-mean                  |
| frequencyBodyGyroscopeJerkMagnitude-StandardDeviation     |