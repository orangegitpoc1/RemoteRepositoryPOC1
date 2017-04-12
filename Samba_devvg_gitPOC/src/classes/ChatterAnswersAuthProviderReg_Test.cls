@isTest 
public class ChatterAnswersAuthProviderReg_Test { 

@isTest private static void verifyInsertChatterFreeUser() { 
//CREATE CHATTER FREE TEST USER 
Profile p = [SELECT id 
FROM profile 
WHERE name = 'Chatter Free User']; 
Auth.UserData u1 = new Auth.UserData('testId', 'FirstName', 'LastName', 'FirstLast', 'test@test.com', null, 'First_abc_last', 'en_US', 'facebook', null, new MAP<String,String>{}); 
ChatterAnswersAuthProviderRegistration caap = new ChatterAnswersAuthProviderRegistration(); 
user uu = caap.createUser(null,u1 ); 

Account a = new Account(); 
a.name = 'test'; 
a.RCE_ID__c = '12345';
//a.Sales_Region__c = 'France';
insert a; 

contact c = new contact(); 
c.lastname = 'last'; 
c.accountid = a.id; 
c.email = 'test@anc.com'; 
c.firstName = 'first'; 
insert c; 

User u2 = new User(alias = 'chfree01', 
email = 'chatterfreeuser101@testorg.com', 
emailencodingkey = 'UTF-8', 
lastname = 'Testing', 
companyname = 'testorg', 
languagelocalekey = 'en_US', 
localesidkey = 'en_US', 
contactid = c.id, 
profileId = p.Id, 
timezonesidkey = 'America/Los_Angeles', 
username = 'chatterfreeuser101@testorg.com'); 
//insert u2; 
Auth.UserData u12 = new Auth.UserData('testId', 'FirstName', 'LastName', 'FirstLast', 'test@test.com', null, 'First_abc_last', 'en_US', 'facebook', null, new MAP<String,String>{}); 
ChatterAnswersAuthProviderRegistration caap1 = new ChatterAnswersAuthProviderRegistration(); 

//caap1.updateUser(u2.id,null,u12 ); 

} 

}