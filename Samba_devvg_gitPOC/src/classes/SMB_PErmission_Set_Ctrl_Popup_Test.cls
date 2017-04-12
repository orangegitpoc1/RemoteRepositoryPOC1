@isTest
public class SMB_PErmission_Set_Ctrl_Popup_Test{

    public static testmethod void method1(){
       Id roleId=[select Id from UserRole limit 1].id;
        
       Profile p = [SELECT Id FROM Profile WHERE Name='Regional Administrator User SAMBA'];
       User usr = TestDataCreation.createUsersWithUsernamePrefixAlias(1, 'Regional Administrator User SAMBA', '1', roleId, 'testpref1', 'tstal1')[0];
       SMB_PErmission_Set_Ctrl_Popup obj=new SMB_PErmission_Set_Ctrl_Popup();
       obj.queryUser='test';
       obj.runQueryUser();
    }



}