/*******************************************************
Created by J. Hazebrouck
When a marketing or sales user is created or changing profile
he is linked to the marketing or sales public group

If the previous profile was marketing or sales, the user is
deleted from the public group
*******************************************************/
public without sharing class SMBW1_User_TR007_AddToGroup_TRG {

	public static void AddUserToGroup(List<User> listUser){
		List<Profile> listProf = [SELECT Id, Name FROM Profile WHERE Name =: 'Marketing User SAMBA'
		OR Name =: 'Sales User SAMBA' OR Name =: 'Bid Approval User SAMBA' OR Name =: 'Sales Team / Support User SAMBA'
		order by Name limit 4];
		List<Group> listGroup = [SELECT Id, DeveloperName FROM Group WHERE
		DeveloperName =: 'SAMBA_Marketing_Users' OR DeveloperName =: 'SAMBA_Sales_Users'
		OR developerName =: 'SAMBA_Sales_Support_Users' order by DeveloperName limit 3];
		List<GroupMember> listMember = new List<GroupMember>();
		
		for(User u : listUser){
			if(u.ProfileId == listProf[1].Id){
				listMember.add(new GroupMember(GroupId = listGroup[0].Id, UserOrGroupId = u.Id));
			}
			else if(u.ProfileId == listProf[3].Id){
				listMember.add(new GroupMember(GroupId = listGroup[2].Id, UserOrGroupId = u.Id));
			}
			else if(u.ProfileId == listProf[0].Id || u.ProfileId == listProf[2].Id){
				listMember.add(new GroupMember(GroupId = listGroup[1].Id, UserOrGroupId = u.Id));
			}
		}
		insert listMember;
	}
	
	public static void DelUserFromGroup(List<User> listUser){
		List<Group> listGroup = [SELECT Id, DeveloperName FROM Group WHERE
		DeveloperName =: 'SAMBA_Marketing_Users' OR DeveloperName =: 'SAMBA_Sales_Users'
		OR developerName =: 'SAMBA_Sales_Support_Users' order by DeveloperName limit 3];
		List<GroupMember> listMember = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember
		WHERE GroupId =: listGroup[0].Id OR GroupId =: listGroup[1].Id OR GroupId =: listGroup[2].Id];
		List<GroupMember> listMemberToDelete = new List<GroupMember>();
		
		for(User u : listUser){
			for(GroupMember gm : listMember){
				if(u.Id == gm.UserOrGroupId)
					listMemberToDelete.add(gm);
			}
		}
		delete listMemberToDelete;
	}
}