# Quick-Change-Set
This tool is native (Apex / Visual Force) based screen. It helps user to upload their Changeset CSV component files at one shot from this screen. It helps users to avoid adding multiple items in changeset with traditional long efforts.

You can install this tool from this un-managed package as well:

https://login.salesforce.com/packaging/installPackage.apexp?p0=04t1U000006d5cW

## Prerequisite
You need to first add your "Quick Change Set" page url domain into remote site settings

## Steps
* Open the Tab "Quick Change Set", it will open the "QuickChangeSet" page
* On the screen, it will ask three inputs
  * Input file: This is the CSV file for the changeset. Here is the [example csv file](https://github.com/ibirds-github/Quick-Change-Set/blob/master/csv-example.csv "example csv file"). 
  **NOTE:** CSV file format and sequences of columns MUST be same as given in csv file.
  * Change Set Id: To get this from your org
    * Open your changeset which you created
    * Click on "Add" button, right click on anywhere from the page to check inspect elements or open the View Source Code window
    * Grab the "id" of changeset from this source code
  * Confirmation Token: To get this from your org
    * From the source code window which you opened in above step, get the value from "_CONFIRMATIONTOKEN" input tag
* Click on "Upload File" button to parse this file. It will show all possible components in bottom table with links. You can click on any output component to go directly to setup record for that component
* Click Confirm Submit to execute the script. It will start adding components into your salesforce changeset
* Once completed, it will show a success message with changeset link
* For more info: [watch here](https://www.youtube.com/watch?v=20f6IIyZNbE)

## Supported Components and Rules to mention in CSV file
For now we are supporting following components. In near future, we need to support more. All names must be case sensitive and must exact match to salesforce Name/DeveloperName exact case
* Apex Classes -> API name of apex class
* Apex Triggers -> API name of apex trigger
* Visualforce Pages -> API name of page
* Visualforce Components -> API name of VF components
* Email Templates -> Email Template Name  
* Static Resources -> API name of static resource
* Custom Objects -> API name of object
* Custom Fields -> [API name of object].[API name of field]
* Workflow Rules -> [API name of object].[Rule Name]
* Email Alerts -> API name of email alert
* Field Updates -> Name of the field update
* Custom Labels -> API name of custom field
* Record Types -> [API name of object].[DeveloperName of record type]
* Page Layouts -> [API name of object].[Name of the layout]


## Known Issues
1. More validations needed on front end side
2. Error handling needed. Right now there is no way to check if a component is added in changeset properly or not. It always shows success message
3. File input required validation needed
4. Few variables may not be useful or can be removed
5. Getting Changeset Id and Confirmation token is from User Input. There seems to be no way to get this dynamically right now.
6. Delete functionality is not given in this tool for now.
7. CSV file format must be same as given in demo file and columns must be in given sequences only
8. This tool is tested on classic salesforce only so far. Not sure how it will work on lightning UI. Need to do couple of changes to support lightning UI
9. All names must be exact same as appear in salesforce (Case Sensitives)
10. In Display output table, it does not show "__c" in object/field names