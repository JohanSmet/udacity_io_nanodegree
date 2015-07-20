# Submission for P3 of the iOS Developer Nanodegree

Assets supplied by Udacity, with exception of IconForward, IconBack and IconDuplicates which were downloaded from Icons8 (https://icons8.com/)

Note about design decisions :

- I decided to filter the data coming from the Parse API to improve the quality of the displayed data. 
  Records with invalid unique keys (e.g. too long, same value as the api documentation) are discarded and
  only one record per student key is retained

- Data is loaded in batches of 100 records and stops when 200 valid records have been loaded or the maximum
  number of requests reached. The data is displayed as it becomes available.

- When the user opens the Information Posting screen again, the previously entered information is already
  filled in and is updated instead of inserted.
   
- The project is divided into multiple groups : 
    - Model
    - View
    - Controllers
    - Clients : interaction with with webApi's'
    - Services : code to accomplish a certain goal but doesn't belong in the Controller