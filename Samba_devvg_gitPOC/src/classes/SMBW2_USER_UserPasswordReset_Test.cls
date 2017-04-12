/**
    About
    -----
    Description: This class is used to test SMBW2_USER_UserPasswordReset_VFC 
    Created for: SAMBA Wave2
    Create date: 2nd Feb 2015
    
    Details
    -------
    This Class test the functionality of SMBW2_USER_UserPasswordReset_Test class.
    1. Test method to upadte/ reset the passwords of the user in the list
    2. Test Data Creation.
    
    Update History
    --------------
    Created Dec 2014 - A.B.
    Mar 2015: OLE, W2.1 replacing profile used in test data: replace Sales User OBS by Standard User Profile (OBS is removed with W2.1)
    
    
    Issues / TODOs
    --------------
   
*/

@isTest
public class SMBW2_USER_UserPasswordReset_Test {
 
static List<User> userList;
static User usr1 = new User(); /*For creating users*/
static User usr2 = new User();
Static String userNamesString = '';
    
public static testMethod void TestUserPasswordReset() {

    createTestData();// Creating dummy users
    Test.startTest();
    for (User uName : userList){
        userNamesString = userNamesString + ' ' + uName.UserName;
    } 


    SMBW2_USER_UserPasswordReset_VFC file = new SMBW2_USER_UserPasswordReset_VFC();
    file.body = Blob.valueOf(userNamesString);// convering users to Blob

    file.ReadDoc();

    Test.stopTest();

    System.assertEquals(1,file.successfulUsers.size());

}

    public static void createTestData(){    
        userList = new List<User>();
        //creating a user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        usr1.alias = 'alTest';
        usr1.email = 'test999@orange.com';
        usr1.profileid = p.Id;   
        usr1.localesidkey ='en_US';
        usr1.timezonesidkey ='America/Los_Angeles';
        usr1.username ='test@devTest.com.test';
        usr1.CommunityNickname = 'test@devTest.com.test';
        usr1.languagelocalekey ='en_US';
        usr1.FirstName ='FN';
        usr1.LastName ='LN';
        usr1.emailencodingkey ='UTF-8';
        userList.add(usr1);
        //creating user2
        usr2.alias = 'alTest2';
        usr2.email = 'test99@orange.com';
        usr2.profileid = '00eE0000000nS7u'; //'00eE0000000iW0iIAE'; OLE: W2.1 replacing since this profile is deleted in W2.1
        usr2.localesidkey ='en_US';
        usr2.timezonesidkey ='America/Los_Angeles';
        usr2.username ='test@devTest.com.test2';
        usr2.CommunityNickname = 'test@devTest.com.test2';
        usr2.languagelocalekey ='en_US';
        usr2.FirstName ='FN2';
        usr2.LastName ='LN2';
        usr2.emailencodingkey ='UTF-8';
        userList.add(usr2);
        insert userList;
         
    }
}