/**
* @author Aslam Bari (aslam.bari@ibirdsservices.com)
* @date 2019
*
* @group Quick Change Set
* @group-content 
*
* @description This class is the controller for Quick Change Set page. This fetches the components Ids for 
* utilizing in changeset creation. Few ids can be get by directly SOQL but for others, we need tooling api
* calling.
*/
public class QuickCSController{
    
    public attachment csvFile {get;set;}
    public ChangeSetModel changeSet {get;set;} 
    public List<integer> lstTable {get;set;}    
    public boolean fileUploaded {get;set;}
    public string changesetId {get;set;}
    public string serverUrlInput{get;set;}
    
    public string confirmTokenInput {get;set;}
    
    public QuickCSController(){
        csvFile = new Attachment();
        lstTable = new List<integer>();
        lstTable.add(1);
    }

    public string getConfirmationToken(){
        return confirmTokenInput;
    }
    
    public string getServerUrl(){
        return serverUrlInput;
    }
    
    public void parseCSV() {
        fileUploaded = false;
        string data = csvFile.body.toString();
        changeSet  = new ChangeSetModel();
        String[] dataLines = data.split('\n');
        
        for (Integer i = 1; i < dataLines.size(); i++) {
                string[] csvRecordData = dataLines[i].split(',');
                
                //Apex Classes
                if(!String.isBlank(csvRecordData[0]))
                    changeSet.apexClassMap.put(csvRecordData[0].trim(), null);
                
                //Apex Triggers
                if(!String.isBlank(csvRecordData[1]))
                    changeSet.apexTriggerMap.put(csvRecordData[1].trim(), null);
                
                //Apex Pages
                if(!String.isBlank(csvRecordData[2]))
                    changeSet.apexPageMap.put(csvRecordData[2].trim(), null);
                
                //Visualforce Components
                if(!String.isBlank(csvRecordData[3]))
                    changeSet.apexComponentMap.put(csvRecordData[3].trim(), null);
            
                //Email Templates
                if(!String.isBlank(csvRecordData[4]))
                    changeSet.emailTemplateMap.put(csvRecordData[4].trim(), null);
                
                //Static Resources
                if(!String.isBlank(csvRecordData[5]))
                    changeSet.staticResourceMap.put(csvRecordData[5].trim(), null);
                
                //Custom Objects
                if(!String.isBlank(csvRecordData[6]))                    
                    changeSet.customObjectMap.put(csvRecordData[6].replace('__c','').trim(), null);
            
                //Custom Fields
                if(!String.isBlank(csvRecordData[7])){    
                    string fieldName = csvRecordData[7].trim();
                    string[] fieldParts = fieldName.split('\\.');
                    
                    if(fieldParts[0].contains('__c')){                    
                        changeSet.objectMap.put(fieldParts[0].replace('__c',''), null);
                        changeSet.objectFieldMap.put(fieldParts[0].replace('__c','')+'.'+fieldParts[1].replace('__c',''), null);
                        changeSet.reverseObjectMap.put(fieldParts[0].replace('__c',''), fieldParts[0].replace('__c',''));
                    }else{
                        changeSet.objectFieldMap.put(fieldParts[0]+'.'+fieldParts[1].replace('__c',''), null);
                        changeSet.reverseObjectMap.put(fieldParts[0], fieldParts[0]);
                    }
                    changeSet.customFieldSet.add(fieldParts[1].replace('__c','').trim());
                }
                
                //Workflow Rules
                if(!String.isBlank(csvRecordData[8])){    
                    string layoutName = csvRecordData[8].trim();
                    string[] layoutParts = layoutName.split('\\.');
                    changeSet.workflowRuleMap.put(layoutParts[0]+'.'+layoutParts[1], null);
                    changeSet.reverseObjectMap.put(layoutParts[0], layoutParts[0]);
                    changeSet.workflowRuleSet.add(layoutParts[1].trim());
                }
                
                //Email Alerts
                if(!String.isBlank(csvRecordData[9]))
                    changeSet.emailAlertMap.put(csvRecordData[9].trim(), null);
                
                //Workflow Field Updates
                if(!String.isBlank(csvRecordData[10]))
                    changeSet.workflowUpdateMap.put(csvRecordData[10].trim(), null);
                
                //Custom Labels
                if(!String.isBlank(csvRecordData[11]))
                    changeSet.customLabelMap.put(csvRecordData[11].trim(), null);
                
                //Record Types
                if(!String.isBlank(csvRecordData[12])){    
                    string recordTypeName = csvRecordData[12].trim();
                    string[] recordTypeParts = recordTypeName.split('\\.');
                    
                    changeSet.recordTypeMap.put(recordTypeParts[0]+'.'+recordTypeParts[1], null);
                    changeSet.recordTypeNames.add(recordTypeParts[1].trim());
                }   
                
                //Page Layouts
                if(!String.isBlank(csvRecordData[13])){    
                    string layoutName = csvRecordData[13].trim();
                    string[] layoutParts = layoutName.split('\\.');
                    
                    if(layoutParts[0].contains('__c')){                    
                        changeSet.objectMap.put(layoutParts[0].replace('__c',''), null);
                        changeSet.objectLayoutMap.put(layoutParts[0].replace('__c','')+'.'+layoutParts[1], null);
                    }else{
                        changeSet.objectLayoutMap.put(layoutParts[0]+'.'+layoutParts[1], null);
                        changeSet.reverseObjectMap.put(layoutParts[0], layoutParts[0]);
                    }
                    changeSet.objectLayoutSet.add(layoutParts[1].trim());
                }

        }     
                
        fillSobjectComponentMap(changeSet.apexClassMap, 'ApexClass');
        
        fillSobjectComponentMap(changeSet.apexTriggerMap, 'ApexTrigger');
        
        fillSobjectComponentMap(changeSet.apexPageMap, 'ApexPage');
        
        fillSobjectComponentMap(changeSet.apexComponentMap, 'ApexComponent');
         
        fillSobjectComponentMap(changeSet.emailTemplateMap, 'EmailTemplate');
        
        fillSobjectComponentMap(changeSet.staticResourceMap, 'StaticResource');
        
        if(changeSet.recordTypeMap.size() > 0){
            for(RecordType cls : [select id, DeveloperName, SobjectType from RecordType where DeveloperName in :changeSet.recordTypeNames]){
                changeSet.recordTypeMap.put(cls.SobjectType + '.' + cls.DeveloperName, cls.Id);
            } 
        }

        fillComponentMap(changeSet.customObjectMap.keyset(), changeSet.customObjectMap, changeSet.reverseObjectMap, 'CustomObject', 'DeveloperName');
        
        for(String key : changeSet.customObjectMap.keyset()){
            changeSet.reverseObjectMap.put(changeSet.customObjectMap.get(key), key);
        }
 
        fillComponentMap(changeSet.objectMap.keyset(), changeSet.objectMap, changeSet.reverseObjectMap, 'CustomObject', 'DeveloperName');
        
        for(String key : changeSet.objectMap.keyset()){
            changeSet.reverseObjectMap.put(changeSet.objectMap.get(key), key);
        }
        
        fillComponentMap(changeSet.workflowRuleSet, changeSet.workflowRuleMap, changeSet.reverseObjectMap, 'WorkflowRule', 'Name', true);
        
        fillComponentMap(changeSet.customFieldSet, changeSet.objectFieldMap, changeSet.reverseObjectMap, 'CustomField', 'DeveloperName', true);
        fillComponentMap(changeSet.emailAlertMap.keyset(), changeSet.emailAlertMap, changeSet.reverseObjectMap, 'WorkflowAlert', 'DeveloperName');
        
        fillComponentMap(changeSet.workflowUpdateMap.keyset(), changeSet.workflowUpdateMap, changeSet.reverseObjectMap, 'WorkflowFieldUpdate', 'Name');
        
        fillComponentMap(changeSet.customLabelMap.keyset(), changeSet.customLabelMap, changeSet.reverseObjectMap, 'CustomLabel', 'Name');
        
        fillComponentMap(changeSet.objectLayoutSet, changeSet.objectLayoutMap, changeSet.reverseObjectMap, 'Layout', 'Name', true);
        
        fileUploaded = true;
    }
  
  
  /*******************************************************************************************************
    * @description this method is actually used only for those components which are queried through Tooling Api.
    * @param cmpNameSet source component set
    * @param cmpNameMap source component map
    * @param reverseObjectMap it stores the object name and id map
    * @param objectType the api name of the component object
    * @param nameField the api name of the field based on which we query (DeveloperName / Name)
    * @param isTblFieldExist boolean flag to check if we need to add TableEnumOrId column in query or not
    * @return void
    */
  private void fillComponentMap(set<string> cmpNameSet, map<string,string> cmpNameMap, map<string,string> reverseObjectMap, string objectType, string nameField, boolean isTblFieldExist){
      if(cmpNameMap.size() > 0){
        string allcmpnames = ('\'' + String.join((Iterable<String>)cmpNameSet, '\',\'') + '\'').replaceAll(' ','+'); 
        string query = 'Select+id';    
            
        if(isTblFieldExist)
            query += ',TableEnumOrId';
        
        query += ',' + nameField + '+from+'+objectType+'+WHERE+'+nameField+'+in+(' + allcmpnames + ')';
        string cmpResponse = ExecuteToolingApi(query);
        ComponentResponse fieldObjectResponse = (ComponentResponse) JSON.deserialize(cmpResponse, ComponentResponse.class);
        for(ComponentModel component : fieldObjectResponse.records){
           
           if(isTblFieldExist){
               string objectName = reverseObjectMap.get(component.TableEnumOrId);
               if(objectName != null)
                  cmpNameMap.put(objectName + '.' + (nameField == 'DeveloperName' ? component.DeveloperName : component.Name), component.Id);
           }else{
               cmpNameMap.put((nameField == 'DeveloperName' ? component.DeveloperName : component.Name), component.Id);
           }  
        }
      }
  }
  
  private void fillComponentMap(set<string> cmpNameSet, map<string,string> cmpNameMap, map<string,string> reverseObjectMap, string objectType, string nameField){
      fillComponentMap(cmpNameSet, cmpNameMap, reverseObjectMap, objectType, nameField, false); 
  }
  
  /*******************************************************************************************************
    * @description this method is actually used only for those components which are queried through SOQL.
    * @param recordsNameMap source component map
    * @param objectType the api name of the component object
    * @return void
    */
  private void fillSobjectComponentMap(map<string,string> recordsNameMap, string objectType){
      if(recordsNameMap.size() > 0){
        set<string> recordNames = recordsNameMap.keySet();
        system.debug('---' + recordNames );
        for(Sobject cls : Database.Query('select id, name from ' + objectType + ' where name in :recordNames')){            
            recordsNameMap.put((string)cls.get('Name'), (string)cls.get('Id'));
        } 
      } 
  }
  
  
  /*******************************************************************************************************
    * @description this method is actually calling Tooling Api REST.
    * @param query query to execute in tooling api
    * @return string as response from tooling api
    */
  public string ExecuteToolingApi(string query){
    HttpRequest req = new HttpRequest();
    req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
    req.setHeader('Content-Type', 'application/json');
    req.setEndpoint( URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v45.0/tooling/query/?q='+query);
    req.setMethod('GET');
    Http h = new Http();
    string response = '';
    if(!Test.isrunningtest()){
        HttpResponse res = h.send(req);   
        response = res.getBody();
    }else{
        //dummy mock data for API response (for Test Class)
        response = '{'+
                        '"size": 153,'+
                        '"totalSize": 153,'+
                        '"done": true,'+
                        '"queryLocator": null,'+
                        '"entityTypeName": "WorkflowRule",'+
                        '"records": [{'+
                            '"attributes": {'+
                                '"type": "WorkflowRule",'+
                                '"url": "/services/data/v30.0/tooling/sobjects/WorkflowRule/01Q57000000jhGlEAI"'+
                            '},'+
                            '"Id": "01Q57000000jhGlEAI",'+
                            '"Name": "numbertext",'+
                            '"DeveloperName" : "TEST",'+
                            '"TableEnumOrId" : "WorkflowRule"'+
                        '}]'+
                    '}';
    } 
    return response;
  }
  
  public class ComponentResponse{
      public List<ComponentModel> records{get;set; }
  }
  public class ComponentModel{
      public string Id {get;set;}
      public string DeveloperName {get;set;}
      public string Name {get;set;}
      public string TableEnumOrId {get;set;}
  }
  
  /*******************************************************************************************************
    * @description Change Set Model class containing all components maps with id
    * which will be used on page
    * returns true if enabled.
    */
  public class ChangeSetModel{
      public map<string,string> apexClassMap {get;set;}
      public map<string,string> apexTriggerMap {get;set;}
      public map<string,string> apexPageMap {get;set;}
      public map<string,string> apexComponentMap{get;set;}
      public map<string,string> emailTemplateMap{get;set;}
      public map<string,string> staticResourceMap{get;set;}
      public map<string,string> workflowRuleMap{get;set;}
      public map<string,string> emailAlertMap{get;set;}
      public map<string,string> workflowUpdateMap{get;set;}
      public map<string,string> customLabelMap{get;set;}
      public map<string,string> recordTypeMap{get;set;}
      public map<string,string> objectLayoutMap{get;set;}
      public set<string> objectLayoutSet {get;set;}
      public set<string> recordTypeNames {get;set;}
      public set<string> workflowRuleSet {get;set;}
      public map<string,string> customObjectMap{get;set;}
      public set<string> customFieldSet {get;set;}
      public map<string,string> objectMap {get;set;}
      public map<string,string> fieldMap {get;set;}
      public map<string,string> objectFieldMap {get;set;}
      public map<string,string> reverseObjectMap{get;set;}
      
      public ChangeSetModel(){
          apexClassMap = new map<string,string>();
          apexTriggerMap = new map<string,string>();
          apexPageMap = new map<string,string>();
          apexComponentMap = new map<string,string>();
          emailTemplateMap = new map<string,string>();
          staticResourceMap = new map<string,string>();
          workflowRuleMap = new map<string,string>();
          emailAlertMap = new map<string,string>();
          workflowUpdateMap = new map<string,string>();
          customLabelMap = new map<string,string>();
          recordTypeMap = new map<string,string>();
          objectLayoutMap = new map<string,string>();
          objectLayoutSet = new set<string>();
          workflowRuleSet = new set<string>();
          recordTypeNames = new set<string>();
          customObjectMap = new map<string,string>();
          customFieldSet = new set<string>();
          objectMap = new map<string,string>();
          reverseObjectMap = new map<string,string>();
          fieldMap = new map<string,string>();
          objectFieldMap = new map<string,string>();
      }
      
      public integer getApexClassMapSize(){
          return apexClassMap.size();
      }
      
      public integer getApexTriggerMapSize(){
          return apexTriggerMap.size();
      }
      
      public integer getApexPageMapSize(){
          return apexPageMap.size();
      }
      
      public integer getApexComponentMapSize(){
          return apexComponentMap.size();
      }
      
      public integer getEmailTemplateMapSize(){
          return emailTemplateMap.size();
      }
      
      public integer getStaticResourceMapSize(){
          return staticResourceMap.size();
      }
      
      public integer getCustomLabelMapSize(){
          return customLabelMap.size();
      }
      
      public integer getRecordTypeMapSize(){
          return recordTypeMap.size();
      }
      
      public integer getCustomObjectMapSize(){
          return customObjectMap.size();
      }
      
      public integer getObjectFieldMapSize(){
          return objectFieldMap.size();
      }
      
      public integer getWorkflowRuleMapSize(){
          return workflowRuleMap.size();
      }
      
      public integer getWorkflowUpdateMapSize(){
          return workflowUpdateMap.size();
      }
      
      public integer getObjectLayoutMapSize(){
          return objectLayoutMap.size();
      }
      
      public integer getEmailAlertMapSize(){
          return emailAlertMap.size();
      }
  }
 
}