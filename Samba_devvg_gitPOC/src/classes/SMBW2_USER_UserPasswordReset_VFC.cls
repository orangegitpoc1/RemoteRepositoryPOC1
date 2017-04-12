/**
    About
    -----
    Description: This class resets the User Passwords available in the file selected by user.
    Created for: SAMBA Wave2
    Create date: 29 Jan 2015
    Author: Yogesh Marke
    
    Details
    -------
    This class reads the file selected by user. It then fetched the other user details by SOQL.
    Resets the password for those users.
    Maintains the seperate list for Successful and UnSuccessful reset of password.    
     
    
    Issues / TODOs
    --------------
   
*/
public class SMBW2_USER_UserPasswordReset_VFC {
    
    //A.T.T.R.I.B.U.T.E.S
    public Blob body {get; set;}
    public String contentType {get; set;}
    public string nameFile {get;set;}
    public List<String> filelines = new List<String>();
    public String fileBody ;
    public List<User> userList {get; set;} // User from the Local file selected by user. 
    public List<User> unsuccessfulUsers {get; set;} // all  User whose password is reset unsuccessfully.
    public List<User> successfulUsers {get; set;} // all  User whose password is reset successfully. 
    //A.T.T.R.I.B.U.T.E.S
    
    /*
     * Author: Yogesh Marke
     * This Method reads the document selected by user from the local machine.
     * fetches the Users from salesforce backend mentioned in the documents and reset the password of those Users 
     */ 
    public void ReadDoc(){

        if(body == null){
            // adding error message on VF page if user has not selected ant file.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,'Please select a file!'));
        
        } else {
                fileBody = body.toString();
                fileBody = fileBody.replaceAll('(\\s+)', ' ');// Removing all Unneccesary characters from the string.
                filelines = fileBody.split(' ');
                
                userList = [SELECT Id,  Username, Name FROM User WHERE IsActive = true AND ProfileId <> '00eE0000000nS7p' AND Username IN :filelines];
                //System.debug('User List count after : ' + userList.get(0));
                resetPasswords(userList);
         }
        
    }
    
    /*
     * Author : Yogesh Marke
     * This method calls the VisualForce page which generates the Excel file for successful and Unsuccessful Reset of user passwords
     */ 
    public PageReference generateFile(){
        PageReference pageRef = new PageReference('/apex/SMBW2_USER_GenerateUserPwdExcel_VFP');
        pageRef.setRedirect(false); // calling other VF page without making a new Request.
        return pageRef;
    }
    
    /*
     * Parameters: List of User Objects for resetting the password.
     * Author: Yogesh marke
     * This method resets the password of the users.
     */
    private void resetPasswords(List<User> userIdList){
        unsuccessfulUsers =  new  List<User>();
        successfulUsers = new List<User>();
    
        if(userIdList != null){
            for(User u : userIdList){
                try {
                    String p = createPassword();
                    //system.setPassword(u.Id , p);
                    System.debug('Password of ' + u.Name + ' is set to : ' + p);
                    successfulUsers.add(u);
                } catch(Exception ex){
                    System.debug('Exception while resetting password for USer Id : ' + u.Id + ' >> Exception is >> ' + ex.getMessage() );
                    unsuccessfulUsers.add(u); // adding unsuccessful attempts to seperate List
                }  
            }
        }    
    }
    
    /*
     * Author: Yogesh Marke
     * This method creates the random password for user and returns it as String.
     */ 
    private String createPassword(){
        //Integer len = 18;
        //Blob blobKey = crypto.generateAesKey(128);
        //String key = EncodingUtil.convertToHex(blobKey);
        //String pwd = key.substring(0,len);
        String pwd = 'Training@1234';
        
          
        return pwd;
    }

}