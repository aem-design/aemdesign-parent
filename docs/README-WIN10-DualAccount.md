WINDOWS 10 DUAL ACCOUNT
=================


If you have Dual account SOE you are in a world of pain. 

Following issues you need to understand:

* File ownership, when creating files as admin and non admin account, files made by admin account need to have full access by non admin account, creating a shared folder and giving it full access by both accounts should mediate this.
* Ability to execute Admin applications by non admin account, this is mediated by caching credentials for those executables using Windows native functions, please read up on this  

**Dual Account Setup**

Required if you have Two account, one Normal User and one Admin Account for installing software.

* Create new folder ```C:\shared``` with following structre 
    * apps - Install project related applications. 
    * downloads - Save all required files/tools for instlation here. 
    * projects - your project folder for..... your projects !
    * vms - when you install VirtualBox point your default vm location here.  
* Ensure the ```C:\shared``` folder permisions allow full access to both your local admin account & your regular user account.
    1. Folder Properties - Security Tab - Advanced. choose "Disable inheritance" at the "Block Inheritance" pop up choose "convert inherited permissions into explicit permissions on          this object." Apply -> Ok . 
    2. Add your local administrator and normal non-admin account to the folders permissions, choose "Edit.." --> "Add" in the "Enter the objects names to select" feild enter your             username , Check Names to verify and then click OK.
    3. Select your userid you just added and select " Full Control" from the Permisions Feild. Hit Apply to apply your changes, repeate steps 1 and 2 for your local admin account. 
* Once both userids have been added to   ```C:\shared``` go back to the "Advanced Security Settings " window and choose the option " Replace all child object permission enties with      inheritable permission entries from this object"  this will seed your changes to the entire folder structure. 
* On the first run of CYGWIN Give your Non-Admin account ownership to all files in Cygwin shell by entering the below command: NOTE run CYGWIN as Admin on first use. 

```Bash
chown -R YOUR_USER_NAME:Domain\ Users dev lib tmp usr var bin sbin etc home
```

