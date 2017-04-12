@istest
//TKT-2673: Created for Trigger LeadMapFields
public class  SMBW3_LeadMapFields_TEST{

    public static testmethod void convertLead(){
        
        TestDataCreation.createSplitcommission(1, 'Commission');
        Lead ld=new Lead(firstname='test165', LastName='test14', leadsource='Email', email='test38@test.com', status='Open', company='Test');
        ld.Switchboard__c='1234567890';
        ld.Phone='2345678901';
        insert ld;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(ld.id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);


        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Id contactId=lcr.getContactId();
        Contact cont=[SELECT id, phone, otherphone from Contact where id=:contactId];
     //   System.assertEquals(ld.Phone,cont.phone);
      //  System.assertEquals(ld.Switchboard__c,cont.otherphone);
    }
    
}