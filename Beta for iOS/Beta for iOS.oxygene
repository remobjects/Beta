<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003" DefaultTargets="Build" ToolsVersion="4.0">
    <PropertyGroup>
        <RootNamespace>Beta</RootNamespace>
        <ProjectGuid>480657f7-06ad-4a0c-b214-a9f3bf6bd4e5</ProjectGuid>
        <OutputType>Executable</OutputType>
        <AssemblyName>Beta</AssemblyName>
        <AllowGlobals>False</AllowGlobals>
        <AllowLegacyWith>False</AllowLegacyWith>
        <AllowLegacyOutParams>False</AllowLegacyOutParams>
        <AllowLegacyCreate>False</AllowLegacyCreate>
        <AllowUnsafeCode>False</AllowUnsafeCode>
        <Configuration Condition="'$(Configuration)' == ''">Release</Configuration>
        <SDK>iOS</SDK>
        <CreateAppBundle>True</CreateAppBundle>
        <InfoPListFile>.\Resources\Info.plist</InfoPListFile>
        <DeploymentTargetVersion>7.0</DeploymentTargetVersion>
        <Name>Beta for iOS</Name>
        <CreateHeaderFile>False</CreateHeaderFile>
        <BundleIdentifier>com.remobjects.Everwood.Beta</BundleIdentifier>
        <Architecture>arm64;armv7</Architecture>
        <DeploymentTargetVersionHints>true</DeploymentTargetVersionHints>
        <CodesignCertificateName>iPhone Distribution: RemObjects Software (24G43Y5373)</CodesignCertificateName>
        <EntitlementsFile>.\Resources\Entitlements.entitlements</EntitlementsFile>
        <BundleVersion>1.0.15</BundleVersion>
    </PropertyGroup>
    <PropertyGroup Condition=" '$(Configuration)' == 'Debug' ">
        <Optimize>false</Optimize>
        <OutputPath>.\bin\Debug</OutputPath>
        <DefineConstants>DEBUG;TRACE;</DefineConstants>
        <GenerateDebugInfo>True</GenerateDebugInfo>
        <EnableAsserts>True</EnableAsserts>
        <TreatWarningsAsErrors>False</TreatWarningsAsErrors>
        <CaptureConsoleOutput>False</CaptureConsoleOutput>
        <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
        <SimulatorArchitectures>i386</SimulatorArchitectures>
        <CreateIPA>True</CreateIPA>
        <GenerateDSym>True</GenerateDSym>
        <ProvisioningProfileName>Beta Develop</ProvisioningProfileName>
        <ProvisioningProfile>de11baa6-acfa-48ce-b195-d60ee65e730e</ProvisioningProfile>
        <CodesignCertificateName>iPhone Developer: marc hoffman (K2YTD84U6W)</CodesignCertificateName>
    </PropertyGroup>
    <PropertyGroup Condition=" '$(Configuration)' == 'AdHoc' ">
        <Optimize>false</Optimize>
        <OutputPath>.\bin\AdHoc\</OutputPath>
        <DefineConstants>DEBUG;TRACE;</DefineConstants>
        <GenerateDebugInfo>True</GenerateDebugInfo>
        <EnableAsserts>True</EnableAsserts>
        <TreatWarningsAsErrors>False</TreatWarningsAsErrors>
        <CaptureConsoleOutput>False</CaptureConsoleOutput>
        <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
        <ProvisioningProfile>d31fcc9b-2995-438a-ad2a-741d9db5f228</ProvisioningProfile>
        <ProvisioningProfileName>Beta AdHoc</ProvisioningProfileName>
        <CreateIPA>True</CreateIPA>
        <GenerateDSym>True</GenerateDSym>
    </PropertyGroup>
    <PropertyGroup Condition=" '$(Configuration)' == 'Release' ">
        <Optimize>False</Optimize>
        <OutputPath>.\bin\Release</OutputPath>
        <GenerateDebugInfo>True</GenerateDebugInfo>
        <EnableAsserts>False</EnableAsserts>
        <TreatWarningsAsErrors>False</TreatWarningsAsErrors>
        <CaptureConsoleOutput>False</CaptureConsoleOutput>
        <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
        <ProvisioningProfile>9d241e49-512f-4c26-bac6-e183f3f1e9f2</ProvisioningProfile>
        <ProvisioningProfileName>Beta App Store</ProvisioningProfileName>
        <CreateIPA>True</CreateIPA>
        <SimulatorArchitectures>i386</SimulatorArchitectures>
        <GenerateDSym>True</GenerateDSym>
    </PropertyGroup>
    <ItemGroup>
        <Reference Include="CoreGraphics.fx"/>
        <Reference Include="Foundation.fx"/>
        <Reference Include="libRemObjectsSDK.fx"/>
        <Reference Include="UIKit.fx"/>
        <Reference Include="rtl.fx"/>
        <Reference Include="libNougat.fx"/>
    </ItemGroup>
    <ItemGroup>
        <Compile Include="AppDelegate.pas"/>
        <Compile Include="Helpers.pas"/>
        <Compile Include="DataAccess.pas"/>
        <Compile Include="DetailViewController.pas"/>
        <Compile Include="LoginViewController.pas"/>
        <Compile Include="MasterViewController.pas"/>
        <Compile Include="Program.pas"/>
        <Compile Include="PushProvider_Intf.pas"/>
        <Compile Include="..\TwinPeaks\iOS\Oxygene\TPBaseCell.pas"/>
        <Compile Include="..\TwinPeaks\iOS\Oxygene\TPBaseCellView.pas"/>
        <Compile Include="..\TwinPeaks\iOS\Oxygene\TPHeaderView.pas"/>
        <Compile Include="WebViewController.pas"/>
    </ItemGroup>
    <ItemGroup>
        <AppResource Include="Resources\EmptyAppLogo%402x.png">
            <SubType>Content</SubType>
        </AppResource>
        <AppResource Include="Resources\EmptyAppLogo.png">
            <SubType>Content</SubType>
        </AppResource>
        <AppResource Include="Resources\EmptyAppLogo7%402x.png">
            <SubType>Content</SubType>
            <CopyToOutputDirectory>Never</CopyToOutputDirectory>
        </AppResource>
        <AppResource Include="Resources\EmptyAppLogo7.png">
            <SubType>Content</SubType>
            <CopyToOutputDirectory>Never</CopyToOutputDirectory>
        </AppResource>
        <AppResource Include="Resources\ChangeLogs.css">
            <SubType>Content</SubType>
        </AppResource>
        <AppResource Include="Resources\App Icons\App-120.png">
            <SubType>Content</SubType>
        </AppResource>
        <AppResource Include="Resources\App Icons\App-152.png">
            <SubType>Content</SubType>
        </AppResource>
        <AppResource Include="Resources\App Icons\App-76.png">
            <SubType>Content</SubType>
        </AppResource>
        <Content Include="Resources\Info.plist"/>
        <AppResource Include="Resources\LoginBackground%402x.jpg">
            <SubType>Content</SubType>
        </AppResource>
        <AppResource Include="Resources\LoginBackground.jpg">
            <SubType>Content</SubType>
        </AppResource>
        <AppResource Include="Resources\RemObjectsLogo%402x.png">
            <SubType>Content</SubType>
        </AppResource>
        <AppResource Include="Resources\RemObjectsLogo.png">
            <SubType>Content</SubType>
        </AppResource>
        <AppResource Include="Resources\LoginBackground%402x.png">
            <SubType>Content</SubType>
        </AppResource>
        <AppResource Include="Resources\LoginBackground.png">
            <SubType>Content</SubType>
        </AppResource>
        <AppResource Include="Resources\New%402x.png">
            <SubType>Content</SubType>
        </AppResource>
        <AppResource Include="Resources\New.png">
            <SubType>Content</SubType>
        </AppResource>
        <AppResource Include="Resources\Launch Images\Default7-568h@2x.png">
            <SubType>Content</SubType>
        </AppResource>
        <AppResource Include="Resources\Launch Images\Default7%402x.png">
            <SubType>Content</SubType>
        </AppResource>
        <AppResource Include="Resources\App Icons\App-29.png"/>
        <AppResource Include="Resources\App Icons\App-48.png"/>
        <AppResource Include="Resources\App Icons\App-57.png"/>
        <AppResource Include="Resources\App Icons\App-58.png"/>
        <AppResource Include="Resources\App Icons\App-72.png"/>
        <AppResource Include="Resources\App Icons\App-96.png"/>
        <AppResource Include="Resources\App Icons\App-114.png"/>
        <AppResource Include="Resources\App Icons\App-144.png"/>
        <Storyboard Include="Resources\MainStoryboard~iPad.storyboard"/>
        <Storyboard Include="Resources\MainStoryboard~iPhone.storyboard"/>
        <AppResource Include="Resources\App Icons\App-512.png"/>
        <AppResource Include="Resources\Launch Images\Default.png"/>
        <AppResource Include="Resources\Launch Images\Default@2x.png"/>
        <AppResource Include="Resources\Launch Images\Default-568h@2x.png"/>
        <AppResource Include="Resources\Launch Images\Default-Portrait.png"/>
        <AppResource Include="Resources\Launch Images\Default-Portrait@2x.png"/>
        <AppResource Include="Resources\Launch Images\Default-Landscape.png"/>
        <AppResource Include="Resources\Launch Images\Default-Landscape@2x.png"/>
    </ItemGroup>
    <ItemGroup>
        <Folder Include="Resources\"/>
        <Folder Include="Resources\App Icons\"/>
        <Folder Include="Resources\Launch Images\"/>
    </ItemGroup>
    <ItemGroup>
        <Xib Include="LoginViewController~ipad.xib">
            <DependentUpon>LoginViewController.pas</DependentUpon>
        </Xib>
        <Xib Include="LoginViewController~iphone.xib">
            <DependentUpon>LoginViewController.pas</DependentUpon>
        </Xib>
        <Storyboard Include="Resources\Launch.storyboard"/>
        <AppResource Include="Resources\RemObjectsLogo@3x.png"/>
        <AppResource Include="Resources\New@3x.png"/>
        <AppResource Include="Resources\App Icons\App-180.png"/>
        <None Include="Resources\Entitlements.entitlements"/>
    </ItemGroup>
    <Import Project="$(MSBuildExtensionsPath)/RemObjects Software/Oxygene/RemObjects.Oxygene.Nougat.targets"/>
    <PropertyGroup>
        <PreBuildEvent/>
    </PropertyGroup>
</Project>