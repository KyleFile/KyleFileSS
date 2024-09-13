Kyle Minicucci

6/15/2024



<p align="Center"><font size=5><b>Adobe Acrobat Updates with Microsoft Intune</b></font></p>

**Table of Contents**

<!-- TOC -->
<!-- TOC -->

- [Background](#background)
- [Step 1: Download Acrobat MUI Installer](#step-1-download-acrobat-mui-installer)
- [Step 2: Create a working directory](#step-2-create-a-working-directory)
- [Step 3: Adjust the setup.ini file](#step-3-adjust-the-setupini-file)
- [Step 4: Create .mst file](#step-4-create-mst-file)
- [Step 6: Create a PowerShell Script](#step-6-create-a-powershell-script)
- [Step 7: Create the .intunewin File](#step-7-create-the-intunewin-file)
- [Step 8: Add App to Intune](#step-8-add-app-to-intune)
  - [**1. App information**](#1-app-information)
  - [**2. Program**](#2-program)
  - [**3. Requirements**](#3-requirements)
  - [**4. Detection Rules**](#4-detection-rules)
  - [**5. Dependencies**](#5-dependencies)
  - [**6. Supersecense**](#6-supersecense)
  - [**7. Assignments**](#7-assignments)
  - [**8. Review + create**](#8-review--create)
- [Troubleshooting](#troubleshooting)

<!-- /TOC -->
<a id="markdown-background" name="background"></a>

Adobe Acrobat DC now has the ability to act as both Adobe Reader DC and Adobe Acrobat Pro. You can customize your Adobe Acrobat DC installation to allow users without an Adobe subscription to use the free features of Adobe Reader without being prompted to sign into an Adobe account.

This means no more separate Adobe Reader and Adobe Acrobat app deployments in Intune. You can just deploy one app for users with or without an Adobe subscription.

Updating Adobe products using Intune can be a mess since Adobe only offers a single .msi installation file that can only be updated with a corresponding .msp file. Updates are not released as a new .msi file. Also, .exe files are always a headache to deploy and detect so I avoid using the setup.exe installer.

So let’s say you’re currently pushing old versions of Adobe Reader and Adobe Acrobat in your Intune environment. How can we create an Adobe Acrobat update package in Intune to replace these apps?

(For this example, I am using the 64-bit version of Adobe Acrobat)

## Step 1: Download Acrobat MUI Installer
<a id="markdown-step-1%3A-download-acrobat-mui-installer" name="step-1%3A-download-acrobat-mui-installer"></a>

- Download the 64-bit [Acrobat Pro MUI Installer](https://helpx.adobe.com/acrobat/kb/acrobat-dc-downloads.html) (1.01 GB, Multilingual zip file installer)

<img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI01.png">

## Step 2: Create a working directory
<a id="markdown-step-2%3A-create-a-working-directory" name="step-2%3A-create-a-working-directory"></a>

- For this example, I created a folder in C:\temp called “**Adobe-AcrobatX64**” and extract the files from the “**Acrobat_DC_Web_X64_WWMUI.zip**” folder to the **C:\temp\Adobe-AcrobatX64** folder

<img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI02.png">

- To update Adobe Acrobat, you must have an .msp file present in the same folder that your setup files are in (**C:\temp\Adobe-AcrobatX64**). Thankfully, the MUI installer already includes the latest .msp file at the time it is downloaded. In this case, the latest update file is the **AcrobatDCX64Upd2400220857.msp** file (24.002.20857 Optional update, June 15, 2024).

- If you would like to update Acrobat to an older or newer version, visit the [Acrobat Release Notes website](https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/index.html) to download the 64-bit Acrobat .msp update file (**AcrobatDCX64UpdXXXXXXXXXX.msp**) of your choice. Then put the .msp file in the same folder that your setup files are in (**C:\temp\Adobe-AcrobatX64**).  

<img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI03.png">

## Step 3: Adjust the setup.ini file
<a id="markdown-step-3%3A-adjust-the-setup.ini-file" name="step-3%3A-adjust-the-setup.ini-file"></a>

- Right click on the **setup.ini** file and select “**Edit in Notepad**”

<img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI04.png"><img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI05.png">

- Add the following lines to the **setup.ini** file under the **[PatchProduct3]** section:

**[PatchProduct4]**
**ProductType=Acrobat**
**PatchVersion=24.002.20857**
**Path=AcrobatDCX64Upd2400220857.msp**

- Be sure that “**PatchVersion”** and “**Path**” match the .msp file that you are using.
- Save the file **setup.ini** once you’ve added the lines above.

<span style="color:red;">**If you don’t add the .msp to the setup.ini, you will probably receive the error 0x80070663 in Intune/Endpoint Protection during deployment.**</span>



## Step 4: Create .mst file
<a id="markdown-step-4%3A-create-.mst-file" name="step-4%3A-create-.mst-file"></a>

- Download and install the [Acrobat Customization Wizard](https://www.adobe.com/devnet-docs/acrobatetk/tools/Wizard/basics.html)

- Run the Acrobat Customization Wizard

- Go to **File \> Open Package** and navigate to the **AcroPro.msi** file in **C:\temp\Adobe-AcrobatX6**

- Set the following installation settings in the Wizard:

**Personalization Options:**

- Keep **Installation Path** as default
- Check the **EULA Option** box to “**Suppress display of End User License Agreement (EULA)**"

<img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI06.png">

**Installation Options (set these depending on your needs):**

- Select “**Make Acrobat the default PDF viewer**”
- Leave “**Remove previous version of Acrobat**” selected
- Select “**Remove all versions of Reader**” (this may only work with an .exe installation but select it anyway)
- Leave “**Enable Optimization**” selected
- Under “**Run Installation**:” select “**Silently (no interface)**”
- Under “**If reboot required at the end of installation:**” select “Prompt the user for reboot”
  - <span style="color:red;">**No reboot is required for this installation**</span>
- Leave **Application Languages** as is
- Select “**Suppress sign-in in Acrobat**” – this is what enables Acrobat to act as Reader
- Go to **File** > **Save Package** 
- Save to the same folder as your setup files (**C:\temp\Adobe-AcrobatX64**)
- Close the Adobe Customization Wizard (you must close the Wizard before performing [Step 7](#Step 7: Create the .intunewin File))

<img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI07.png">

## Step 6: Create a PowerShell Script
<a id="markdown-step-6%3A-create-a-powershell-script" name="step-6%3A-create-a-powershell-script"></a>

- Open PowerShell ISE and copy the script contents below into a new script file

```powershell
1	 # Copy contents of AcroPro.intunewin file to temp directory
2	 New-Item -Force "C:\temp\Adobe" -ItemType "Directory"
3	 Copy-Item -Path "$PSScriptRoot\*" -Destination "C:\temp\Adobe" -Recurse -Force
4
5	 # Install app from temp directory
6	 msiexec.exe /i "C:\temp\Adobe\AcroPro.msi" TRANSFORMS="C:\temp\Adobe\AcroPro.mst" PATCH=C:\temp\Adobe\ AcrobatDCX64Upd2400220857.msp /qn /l*v c:\temp\Adobe_DC_Install.log
7
8	 Start-Sleep -Seconds 60
9	 # Clean up temp directory
10 Remove-Item -Path "C:\temp\Adobe" -Recurse -Force -Confirm:$false
```

- <span style="color:red;">**NOTE: MAKE SURE THE .msp FILE NAME IN LINE 6 IS CORRECT**</span>

<img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI08.png">

- Name the script **Install-AdobeAcrobat.ps1** and save it in **C:\temp\Adobe-AcrobatX64**

## Step 7: Create the .intunewin File
<a id="markdown-step-7%3A-create-the-.intunewin-file" name="step-7%3A-create-the-.intunewin-file"></a>

- If you do not already have the **Microsoft Win32 Content Prep Tool** installed already, you can downlad the **IntuneWinAppUtil.exe** file from [Microsoft's GitHub page](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/blob/master/IntuneWinAppUtil.exe)

- Open the **IntuneWinAppUtil.exe** application and enter the following:

- **Please specify the source folder:** C:\temp\Adobe-AcrobatX64

- **Please specify the setup file:** AcroPro.msi

- **Please specify the output folder:** C:\temp\Adobe-AcrobatX64

- **Do you want to specify catalog folder (Y/N)?:** N

- It may take some time to generate the .intunewin file. 

- Once complete, you should see a file called “AcroPro.intunewin” in your **C:\temp\Adobe-AcrobatX64** folder

  <img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI09.png">

## Step 8: Add App to Intune
<a id="markdown-step-8%3A-add-app-to-intune" name="step-8%3A-add-app-to-intune"></a>

- Sign into the Microsoft Intune admin center

- Go to **Apps** >  **By Platform** > **Windows**

- Click the **+ Add** button and select **Windows app (Win32)** from the App type dropdown

- Click the **Select** button at the bottom to proceed 

  <img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI10.png">

#### **1. App information**
<a id="markdown-**1.-app-information**" name="**1.-app-information**"></a>

- **Select File:** Upload the **AcroPro.intunewin** file created in STEP 6

- **Name:** Adobe Acrobat DC (64-bit)

- **Description:** Add a detailed description.

- **Publisher:** Adobe

- **App Version:** Put the version of the .msp file (i.e. 24.002.20857)

- Leave everything else as default and click **Next** 

<img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI11.png">

#### **2. Program**
<a id="markdown-**2.-program**" name="**2.-program**"></a>

- **Install command**: Powershell.exe -NoProfile -ExecutionPolicy ByPass -File .\Install-AdobeAcrobat.ps1

- **Uninstall command**: msiexec /x "{AC76BA86-1033-FFFF-7760-BC15014EA700}" /qn

- Leave everything else as default and click **Next**

<img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI12.png">

#### **3. Requirements**
<a id="markdown-**3.-requirements**" name="**3.-requirements**"></a>

- **Operating system architecture:** Select both **32-bit** and **64-bit**
- **Minimum operating system:** Windows 10 1607
- Leave everything as default and click **Next**

<img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI13.png">

#### **4. Detection Rules**
<a id="markdown-**4.-detection-rules**" name="**4.-detection-rules**"></a>

- Create a detection rule to detect the MSI product code and version after installation

  - **Rules format:** Manually configure detection rules
  - **Type:** Click the **+ Add** button 
    - **Rule Type:** MSI
    - **MSI Product code:** {AC76BA86-1033-FFFF-7760-BC15014EA700}
    - **MSI product version check:** Yes
    - **Operator:** Equals
    - **Value:** 24.002.21005 (.msp file version)
    - Click **OK**


  <img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI14.png">

  - Leave everything as default and click **Next**

<img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI15.png">

#### **5. Dependencies**
<a id="markdown-**5.-dependencies**" name="**5.-dependencies**"></a>

- No dependencies. 
- Click **Next**

#### **6. Supersecense**
<a id="markdown-**6.-supersecense**" name="**6.-supersecense**"></a>

- No supersedence necessary. Previous versions of Adobe Reader or Adobe Acrobat will automatically uninstall and be replaced with the new Adobe Acrobat being deployed via Intune
- Click **Next**

#### **7. Assignments**
<a id="markdown-**7.-assignments**" name="**7.-assignments**"></a>

- Assign the application to a user or device group
- Click **Next**

#### **8. Review + create**
<a id="markdown-**8.-review-%2B-create**" name="**8.-review-%2B-create**"></a>

- Review your steps to ensure everything looks correct
- Click **Create**
- It may take awhile for the app package to upload to Intune depending on your upload speed

<img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI16.png">

**You have completed deploying Adobe Acrobat with updates. **

**Test the installation on a group of test users and devices first.**

<span style="color:blue;">**When it comes time to update Adobe Acrobat again, just follow this process over using the lastest 64-bit Acrobat .msp update file (see end of STEP 2)**</span>

## Troubleshooting
<a id="markdown-troubleshooting" name="troubleshooting"></a>

- I have come across two scenarios of installation failures:

  1. Installation fails because a user has an Adobe program running at the time Intune attempts to install Adobe Acrobat. 

     - Usually the installation will automatically attempt to close any running Adobe programs, but if not, Intune will attempt to install the application again at next check-in

  2. Note 1708: Unable to create a temp copy of patch 'AcrobatDCx64Upd2400220857.msp'.

     - You may receive this error if the .intunewin file does not contain the .msp file. This can happen if you adjust the **setup.ini** file (STEP 3) AFTER already having run the Adobe Customization Wizard (STEP 4)

     - You can check the contents of your .intunewin file by using the IntuneWinAppUtilDecoder tool. It can be installed from Microsoft's GitHub page [Microsoft's GitHub page](https://github.com/okieselbach/Intune/blob/master/IntuneWinAppUtilDecoder/IntuneWinAppUtilDecoder/bin/Release/IntuneWinAppUtilDecoder.zip)
  
       - Download the .zip folder
       - Extract the .AcroPro.intunewin file using the IntuneWinAppUtilDecoder tool

       <img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI17.png">
  
       - This will create an **AcroPro.decoded.zip** folder in the location of the **AcroPro.intunewin** file. 
       
         <img src="https://raw.githubusercontent.com/KyleFile/KyleFileSS/main/Images/AAUWI18.png">
       
       - Open the .zip folder and check if the .msp file is there. If it isn't, verify the .msp file is in the **C:\temp\Adobe-AcrobatX64** folder and then re-create the .intunewin file (STEP 6)
