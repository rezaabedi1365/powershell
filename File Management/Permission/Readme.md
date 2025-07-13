بسیار خوب! در ادامه نسخه‌ای از اسکریپت PowerShell برای بکاپ گرفتن از **Share Permissions به صورت فایل CSV** آورده شده است:

---

### ✅ اسکریپت PowerShell برای گرفتن Share Permissions و ذخیره در فایل CSV:

```powershell
$allPermissions = @()

Get-SmbShare | ForEach-Object {
    $share = $_
    $permissions = Get-SmbShareAccess -Name $share.Name

    foreach ($perm in $permissions) {
        $allPermissions += [PSCustomObject]@{
            ShareName         = $share.Name
            SharePath         = $share.Path
            Description       = $share.Description
            AccountName       = $perm.AccountName
            AccessControlType = $perm.AccessControlType
            AccessRight       = $perm.AccessRight
        }
    }
}

$allPermissions | Export-Csv -Path "C:\Backup\share_permissions.csv" -NoTypeInformation -Encoding UTF8
```

---

### 📂 خروجی فایل `share_permissions.csv` شامل ستون‌های زیر خواهد بود:

* **ShareName**: نام اشتراک
* **SharePath**: مسیر فیزیکی پوشه
* **Description**: توضیحات اشتراک
* **AccountName**: حساب یا گروهی که دسترسی دارد
* **AccessControlType**: نوع دسترسی (Allow / Deny)
* **AccessRight**: سطح دسترسی (Full, Change, Read, etc.)

---

اگر بخوای بعداً همین CSV رو دوباره برای ریستور استفاده کنی، می‌تونم برات اسکریپت ریستور هم بنویسم. فقط بگو.

حتماً! در ادامه اسکریپتی برای **ریستور کردن Share Permissions از فایل CSV** که قبلاً تهیه کردی آورده‌ام:

---

### ✅ اسکریپت PowerShell برای ریستور کردن Share Permissions از فایل CSV:

```powershell
# مسیر فایل CSV بکاپ
$csvPath = "C:\Backup\share_permissions.csv"

# خواندن فایل CSV
$permissions = Import-Csv -Path $csvPath

foreach ($entry in $permissions) {
    try {
        # اضافه کردن دسترسی به Share
        Grant-SmbShareAccess `
            -Name $entry.ShareName `
            -AccountName $entry.AccountName `
            -AccessRight $entry.AccessRight `
            -Force
        Write-Host "✔️ Granted $($entry.AccessRight) to $($entry.AccountName) on $($entry.ShareName)"
    }
    catch {
        Write-Warning "⚠️ Failed to set permission for $($entry.AccountName) on $($entry.ShareName): $_"
    }
}
```

---

### ⚠️ نکات مهم:

1. این اسکریپت فرض می‌کند که **shareها قبلاً ایجاد شده‌اند**.

   * اگر share موجود نیست، باید اول با `New-SmbShare` ساخته بشه.
2. `Grant-SmbShareAccess` به صورت پیش‌فرض اجازه‌ی **مقادیر زیر** را برای `-AccessRight` می‌پذیرد:

   * `Full`
   * `Change`
   * `Read`
3. اگر `-AccessControlType` در CSV هست (یعنی Allow یا Deny)، می‌تونی پارامتر `-AccessControlType` رو هم اضافه کنی:

   ```powershell
   -AccessControlType $entry.AccessControlType
   ```

---

### 🧪 اگر می‌خوای قبل از اجرای واقعی فقط چک کنی (dry run):

```powershell
Write-Host "Would grant $($entry.AccessRight) to $($entry.AccountName) on $($entry.ShareName)"
```

---

اگر نیاز داری Shareها رو هم همراه با Permission از CSV بسازی (یعنی ShareName و Path)، می‌تونم نسخه کامل ساخت Share + Permission رو هم برات بنویسم. فقط بگو.












----------------------------------------------------------------------------------

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
