BeforeAll {
    $root = Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath "../MyModule")
    Import-Module $root -Force   
}

Describe "Tests" {
    It "should validate manifest file" {
        $Manifest = Resolve-Path (Join-Path $root -ChildPath "MyModule.psd1")
        $Test = Test-ModuleManifest $Manifest

        $Test | Should -BeOfType [System.Management.Automation.PSModuleInfo]
        $Test.Name | Should -Be "MyModule"
        [guid]$Test.Guid | Should -BeOfType guid
    }

    It "should use the private Get-World function" {
        InModuleScope MyModule {
            Get-World | Should -Be "World"
        }
    }

    It "should Run Public Function with default" {
        Use-PublicFunction | Should -Be "Hello, World!"
    }

    It "should Run Public Function with parameter" {
        Use-PublicFunction -Name "Foo" | Should -Be "Hello, Foo!"
    }

    It "should Run Public Function with Alias" {
        upf | Should -Be "Hello, World!"
    }
}
