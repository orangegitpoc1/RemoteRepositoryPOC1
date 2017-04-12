@isTest(SeeAllData=true)
Private class SMBW3_Update_Ust_Trigger_Test{
    static testMethod void myUnitTest(){
    
    list<UAT_Scenario__c> us=[select id,User_Story__c from UAT_Scenario__c where User_Story__c!=null];
    Release__c rc=[select id from Release__c limit 1];
    Defects__c DE=new Defects__c(Domain__c='Forcasting',Type__c='Defect',Title__c='Defect',Severity__c='High',Issue_and_Description__c='DEfect',
    Expected_Result__c='Defect',Actual_Result__c='defect',
    Detection_Date__c=system.today(),Status__c='1.New',UAT_Scenario__c=us[0].id,Release__c=rc.id); 
    system.assert(us.size()>0);
    System.assert(rc!=null);
    insert DE;
    
    Defects__c DEF= new Defects__c(id=DE.id);
    update DEF;
    
    }


}