برای گرفتن بکاپ از **پرمیژن‌های share (اشتراک‌گذاری)** مربوط به یک فولدر در ویندوز (مانند Share Permissions نه NTFS Permissions)، می‌توانی از PowerShell استفاده کنی. در ادامه یک روش دقیق برای بکاپ گرفتن از Share Permissions آورده شده است:

---

### ✅ گرفتن لیست Share ها و Permissions مربوطه با PowerShell:

```powershell
Get-SmbShare | ForEach-Object {
    $shareName = $_.Name
    $permissions = Get-SmbShareAccess -Name $shareName

    [PSCustomObject]@{
        ShareName   = $shareName
        Path        = $_.Path
        Description = $_.Description
        Permissions = $permissions | Select-Object Name, AccessControlType, AccountName
    }
} | Export-Clixml -Path "C:\Backup\share_permissions_backup.xml"
```

🔸 این اسکریپت:

* لیست تمام Share ها را می‌گیرد.
* برای هر Share، دسترسی‌ها را با `Get-SmbShareAccess` جمع‌آوری می‌کند.
* خروجی را به صورت XML در مسیر مشخص‌شده ذخیره می‌کند.

---

### ✅ ریستور کردن Share Permissions:

برای ریستور کردن این اطلاعات (البته باید به شکل مناسب پردازش شود):

```powershell
$backup = Import-Clixml -Path "C:\Backup\share_permissions_backup.xml"

foreach ($item in $backup) {
    foreach ($perm in $item.Permissions) {
        Grant-SmbShareAccess -Name $item.ShareName -AccountName $perm.AccountName -AccessRight $perm.AccessControlType -Force
    }
}
```

> ⚠️ توجه:
>
> * این فقط Share Permissions را بکاپ می‌گیرد، نه NTFS permissions.
> * برای NTFS permissions باید از `icacls` یا `Get-Acl` استفاده شود.

---

### 🎯 اگر فقط یک فولدر خاص مدنظر است:

اگر فقط یک فولدر خاص Share شده را می‌خواهی، کافی است `Get-SmbShare -Name "ShareName"` را به جای `Get-SmbShare` بنویسی.

مثال:

```powershell
$share = Get-SmbShare -Name "MySharedFolder"
$permissions = Get-SmbShareAccess -Name $share.Name

[PSCustomObject]@{
    ShareName   = $share.Name
    Path        = $share.Path
    Description = $share.Description
    Permissions = $permissions | Select-Object Name, AccessControlType, AccountName
} | Export-Clixml -Path "C:\Backup\MySharedFolder_Permissions.xml"
```

---

اگر بخوای یک نسخه متنی (نه XML) داشته باشی که راحت‌تر قابل خواندن یا مستندسازی باشه، بگو تا نسخه Text یا CSV هم برات بنویسم.
