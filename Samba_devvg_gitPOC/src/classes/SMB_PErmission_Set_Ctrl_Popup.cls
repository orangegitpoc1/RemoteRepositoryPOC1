public class SMB_PErmission_Set_Ctrl_Popup {
    public String queryUser {get; set;}
    public List<User> listUser {get; set;}
    
    public PageReference runQueryUser()
    {
        List<List<User>> searchResults=[FIND :queryUser IN ALL FIELDS RETURNING User (id, name, username)];
        listUser=searchResults[0];
        return null;
    }
}