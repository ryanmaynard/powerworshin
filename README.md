# 🧹 PowerWorshin 🪣

#### When you need somethin' done about all them empty folders on your drive, let ole Uncle Terry pop in a zyn and get ta cleanin'

---

### 🏞️ What's PowerWorshin all about?

PowerWorshin is a smart PowerShell script that'll clean up those empty folders quicker'n you can say "Raise Hell, Praise Dale". It's like givin' your computer a good once-over: it ain't a deep clean, just a good go at the jewels and pits. 
---

### 🛠️ How do I get this thing goin'?

1. 📥 First off, grab this script. Download `powerworshin.ps1` and stick it on your computer.

2. 🖥️ Open up that PowerShell program. It's like Command Prompt but more fancy.

3. 🚶‍♂️ Use them `cd` commands to get to where you put the script.

4. 🎬 Now, let's fire this thing up and see what she does! Here's the basic way to run it:

   ```powershell
   .\powerworshin.ps1 -RootPath "C:\Users\YourName\Documents"
   ```

---

### 🎛️ Extra Doohickeys

- 🚫 **Hands Off My Stuff**: Don't want it messin' with certain folders? Use `-ExcludePaths`:
  ```powershell
  .\powerworshin.ps1 -RootPath "C:\Users\YourName\Documents" -ExcludePaths "C:\Users\YourName\Documents\KeepThisOne"
  ```

- 🕰️ **Just the Old Stuff**: Wanna only clean out folders older than last year's Christmas tree? Use `-MinimumAge`:
  ```powershell
  .\powerworshin.ps1 -RootPath "C:\Users\YourName\Documents" -MinimumAge 30
  ```

- 🧪 **Look-See Without Touchin'**: Wanna see what it'll do without actually doin' it? Use `-DryRun`:
  ```powershell
  .\powerworshin.ps1 -RootPath "C:\Users\YourName\Documents" -DryRun
  ```

- 💪 **Git 'Er Done**: If you're feelin' sure and don't need no askin', use `-Force`:
  ```powershell
  .\powerworshin.ps1 -RootPath "C:\Users\YourName\Documents" -Force
  ```

- 📦 **Save Your Hide**: Want a way to undo if you mess up? Use `-CreateBackup`:
  ```powershell
  .\powerworshin.ps1 -RootPath "C:\Users\YourName\Documents" -CreateBackup
  ```

---

### ⚠️ Fair Warnin' to Ya

Now listen, and listen good. This script's more powerful than Mamaw's secret recipe. It'll delete empty folders faster than you can spit. So, make good and sure you know what you're doin' before you let it loose!

1. 🧪 Always do a `-DryRun` first to see what's gonna get cleaned out.
2. 📦 Use that `-CreateBackup` option if you're even a little bit unsure.
3. 🎓 If you don't know what somethin' does, don't use it! Ask for help or read up on it first.

---

### 🆘 Need a Hand?

If you're more confused than a chameleon in a bag of Skittles, don't you worry none. Just holler at us by openin' an issue right here on GitHub. We're friendlier than a neighbor with a fresh pie, and we'll do our best to help you out!

---

### 🍎 Happy Cleanin', Folks!

Now go on and clean them folders! Your computer'll be runnin' smoother than a freshly paved mountain road in no time!