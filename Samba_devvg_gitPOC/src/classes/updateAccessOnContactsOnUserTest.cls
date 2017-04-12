@isTest
class updateAccessOnContactsOnUserTest{

public static TestMethod void updateContactAccesstest(){
    List<UserRole> usrRoles=TestDataCreation.createUserRoles(2, null);
    usrRoles[1].name=Label.SMB_CL039_RoleContactPrivate+' Account';
    update usrRoles[1];
    User usr=TestDataCreation.createUsers(1, 'System Administrator', '1', usrRoles[0].id)[0];
    System.runAs(usr) {
        Test.startTest();
        Account acc=TestDataCreation.createAccounts(1)[0];
        Contact cont=TestDataCreation.createContactsWithAccount(1, acc.Id, 'Test1')[0];
        cont.ownerId=usr.id;
        update cont;
        cont=[select id, ownerId, SMB_Keep_Private_Text__c from Contact where id=:cont.id];
        System.assertNotEquals(cont.SMB_Keep_Private_Text__c, 'True');    
        usr.UserRoleId=usrRoles[1].id;
        update usr;
        Test.stopTest();
    }
}


}