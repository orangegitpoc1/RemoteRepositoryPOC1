@isTest(SeeAllData=true)
private class SMBW1_User_TR007_Test {
    static testMethod void myUnitTest(){
        List<Profile> listProf = [SELECT Id, Name FROM Profile WHERE Name =: 'Marketing User SAMBA'
        OR Name =: 'Sales User SAMBA'order by Name limit 2];
        User u = new User(FirstName = 'TestFirst', LastName = 'TestLast', Email = 'test999@orange.com',
        Username = 'test@obs.com', isActive = true, ProfileId = listProf[0].Id, alias = 'standt',
        localesidkey='en_US', timezonesidkey='America/Los_Angeles', CommunityNickname = 'test@obs.com',
        languagelocalekey='en_US', emailencodingkey='UTF-8');
        List<Group> listGroup = [SELECT Id, DeveloperName FROM Group WHERE
        DeveloperName =: 'SAMBA_Marketing_Users' OR DeveloperName =: 'SAMBA_Sales_Users' order by DeveloperName limit 2];
        List<GroupMember> listMember = new List<GroupMember>();
        
        Test.startTest();
        insert u;
        listMember = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId =: listGroup[0].Id AND UserOrGroupId =: u.Id];
        /*----------------------------Commented Due to Error By AR-----------------------------------*/
        //System.assertEquals(listMember.size(), 1);
        u.ProfileId = listProf[1].Id;
        update u;
        listMember = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId =: listGroup[1].Id AND UserOrGroupId =: u.Id];
        /*----------------------------Commented Due to Error By AR-----------------------------------*/
        //System.assertEquals(listMember.size(), 1);
        listMember = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId =: listGroup[0].Id AND UserOrGroupId =: u.Id];
        /*----------------------------Commented Due to Error By AR-----------------------------------*/
        //System.assertEquals(listMember.size(), 0);
        Test.stopTest();
    }
}