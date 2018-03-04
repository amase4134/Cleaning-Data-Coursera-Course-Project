library(reshape2)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load activity labels + features
ActivityHeaders <- read.table("UCI HAR Dataset/activity_labels.txt")
ActivityHeaders[,2] <- as.character(ActivityHeaders[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresNeeded <- grep(".*mean.*|.*std.*", features[,2])
featuresNeeded.names <- features[featuresNeeded,2]
featuresNeeded.names = gsub('-mean', 'Mean', featuresNeeded.names)
featuresNeeded.names = gsub('-std', 'Std', featuresNeeded.names)
featuresNeeded.names <- gsub('[-()]', '', featuresNeeded.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresNeeded]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresNeeded]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
CombinedData <- rbind(train, test)
colnames(CombinedData) <- c("subject", "activity", featuresNeeded.names)

# turn activities & subjects into factors
CombinedData$activity <- factor(CombinedData$activity, levels = ActivityHeaders[,1], labels = ActivityHeaders[,2])
CombinedData$subject <- as.factor(CombinedData$subject)

CombinedData.melted <- melt(CombinedData, id = c("subject", "activity"))
CombinedData.mean <- dcast(CombinedData.melted, subject + activity ~ variable, mean)

write.table(CombinedData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)