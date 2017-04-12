/*
Orange id :162487
created on :26/7/2016
UST-01262 
This is extension class of vf page 'SMB_Competitor_Delete' we handle delete functionality of competitor.
not allowing primary competitor to be deleted 
*/
public with sharing class SMB_Competitor_Delete {
  competitor__c COMpe;
  competitor__c c;
  List<Competitor__c> listCompetitor=new list<Competitor__c>();
    public SMB_Competitor_Delete(ApexPages.StandardController controller) {  // constructor with standard controller as parameter
        c=new competitor__c();
        COMpe =(Competitor__c)controller.getRecord();
        c=[select id,Opportunity__c,SMB_OPCOM_Primary__c from Competitor__c where id=:COMpe.id];                 // query to get other field record of competitor
        listCompetitor=[select id,Opportunity__c from Competitor__c where Opportunity__c=:c.Opportunity__c ];    //get other competitor associated with Opportunity
    }
    public PageReference check(){                                                                                       // action function of vf page                          
       if(c.SMB_OPCOM_Primary__c && listCompetitor.size()>1){                                                            // if competitor is primary and only one  primary competitor 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,System.label.SMB_Competitor_Delete);  // error You Cannot Delete a Primary Competitor
            ApexPages.addMessage(myMsg);
            return null;
       }
       else{                                                                         // else opportunity contains more than one competitor                       
       try{
           delete c;
           return(new Pagereference('/'+c.Opportunity__c));                            // return to opportunity page 
           }
       Catch(Exception e){
               ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,System.label.SMB_Competior_Stage_3);
               ApexPages.addMessage(myMsg);
               return null;
       }    
       }
    }
    
    public PageReference backfunction(){                                                        // back button call this method
    
        return(new Pagereference('/'+c.Opportunity__c));                                // return to opportunity page
    }

}