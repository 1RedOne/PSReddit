Function Get-DecryptedValue{
param($inputObj,$name)

            $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($inputObj)
            $result = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
            [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
            New-Variable -Scope Global -Name $name -Value $result -PassThru -Force
            
}