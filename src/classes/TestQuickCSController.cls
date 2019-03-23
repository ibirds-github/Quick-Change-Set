/**
* @author Aslam Bari (aslam.bari@ibirdsservices.com)
* @date 2019
*
* @group Test Classes
* @group-content 
*
* @description Test coverage class for QuickCSController  
*/
@istest
public class TestQuickCSController {
    
    @istest
    private static void testChangeSetController(){
        string testData = 'Apex Classes,Apex Triggers,Visualforce Pages,Visualforce Components,Email Templates,Static Resources,Custom Objects,Custom Fields,Workflow Rules,Email Alerts,Field Updates,Custom Labels,Record Types,Page Layouts\n' +
                          'superSort,AccountTrigger,ChatterAnswersLogin,site_footer,Account Close,ServiceCloudLogo,Articles__c,Articles__c.Active__c,Account.Book Store Registration On Account,Close_Article_Book_Store,Update Store,Company_Website,Account.Book_Owner,Articles__c.Article Layout';
        QuickCSController qCSCtr = new QuickCSController();
        qCSCtr.csvFile = new Attachment(name='test.csv', Body = Blob.valueOf(testData));
        qCSCtr.parseCSV();
        
        system.assert(qCSCtr.changeset.workflowRuleMap.size() > 0);
    }
}