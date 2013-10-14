<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003" ToolsVersion="4.0">
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
    <SDK>iOS 7.0</SDK>
    <CreateAppBundle>True</CreateAppBundle>
    <InfoPListFile>.\Resources\Info.plist</InfoPListFile>
    <DeploymentTargetVersion>5.0</DeploymentTargetVersion>
    <Name>Beta for iOS</Name>
    <DefaultUses />
    <StartupClass />
    <CreateHeaderFile>False</CreateHeaderFile>
    <BundleIdentifier>com.remobjects.Everwood.Beta</BundleIdentifier>
    <DeploymentTargetVersionHints>true</DeploymentTargetVersionHints>
    <BundleExtension />
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
    <ProvisioningProfile>456DE529-2F1B-4FFD-B714-BCC6F4B9E009</ProvisioningProfile>
    <ProvisioningProfileName>Beta AdHoc</ProvisioningProfileName>
    <CodesignCertificateName>iPhone Distribution: RemObjects Software</CodesignCertificateName>
    <SimulatorArchitectures>i386</SimulatorArchitectures>
    <Architecture>armv7;armv7s</Architecture>
    <CreateIPA>True</CreateIPA>
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
    <ProvisioningProfile>456DE529-2F1B-4FFD-B714-BCC6F4B9E009</ProvisioningProfile>
    <ProvisioningProfileName>Beta AdHoc</ProvisioningProfileName>
    <CodesignCertificateName>iPhone Distribution: RemObjects Software</CodesignCertificateName>
    <CreateIPA>True</CreateIPA>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Release' ">
    <Optimize>true</Optimize>
    <OutputPath>.\bin\Release</OutputPath>
    <GenerateDebugInfo>False</GenerateDebugInfo>
    <EnableAsserts>False</EnableAsserts>
    <TreatWarningsAsErrors>False</TreatWarningsAsErrors>
    <CaptureConsoleOutput>False</CaptureConsoleOutput>
    <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
    <ProvisioningProfile>6EFBFEDC-C774-40BF-8FBC-FD192CFA7815</ProvisioningProfile>
    <ProvisioningProfileName>Beta App Store</ProvisioningProfileName>
    <CodesignCertificateName>iPhone Distribution: RemObjects Software</CodesignCertificateName>
    <Architecture>armv7;armv7s</Architecture>
    <CreateIPA>True</CreateIPA>
    <SimulatorArchitectures>i386</SimulatorArchitectures>
  </PropertyGroup>
  <ItemGroup>
    <Reference Include="CoreGraphics.fx" />
    <Reference Include="Foundation.fx" />
    <Reference Include="libRemObjectsSDK.fx" />
    <Reference Include="UIKit.fx" />
    <Reference Include="rtl.fx" />
    <Reference Include="libNougat.fx" />
  </ItemGroup>
  <ItemGroup>
    <Compile Include="AppDelegate.pas" />
    <Compile Include="Helpers.pas" />
    <Compile Include="DataAccess.pas" />
    <Compile Include="DetailViewController.pas" />
    <Compile Include="LoginViewController.pas" />
    <Compile Include="MasterViewController.pas" />
    <Compile Include="Program.pas" />
    <Compile Include="PushProvider_Intf.pas" />
    <Compile Include="V:\git\Beta\TwinPeaks\iOS\Oxygene\TPBaseCell.pas" />
    <Compile Include="V:\git\Beta\TwinPeaks\iOS\Oxygene\TPBaseCellView.pas" />
    <Compile Include="V:\git\Beta\TwinPeaks\iOS\Oxygene\TPHeaderView.pas" />
    <Compile Include="WebViewController.pas" />
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
    <Content Include="Resources\Info.plist" />
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
    <AppResource Include="Resources\App Icons\App-29.png" />
    <AppResource Include="Resources\App Icons\App-48.png" />
    <AppResource Include="Resources\App Icons\App-57.png" />
    <AppResource Include="Resources\App Icons\App-58.png" />
    <AppResource Include="Resources\App Icons\App-72.png" />
    <AppResource Include="Resources\App Icons\App-96.png" />
    <AppResource Include="Resources\App Icons\App-114.png" />
    <AppResource Include="Resources\App Icons\App-144.png" />
    <Storyboard Include="Resources\MainStoryboard~iPad.storyboard" />
    <Storyboard Include="Resources\MainStoryboard~iPhone.storyboard" />
    <AppResource Include="Resources\App Icons\App-512.png" />
    <AppResource Include="Resources\Launch Images\Default.png" />
    <AppResource Include="Resources\Launch Images\Default@2x.png" />
    <AppResource Include="Resources\Launch Images\Default-568h@2x.png" />
    <AppResource Include="Resources\Launch Images\Default-Portrait.png" />
    <AppResource Include="Resources\Launch Images\Default-Portrait@2x.png" />
    <AppResource Include="Resources\Launch Images\Default-Landscape.png" />
    <AppResource Include="Resources\Launch Images\Default-Landscape@2x.png" />
  </ItemGroup>
  <ItemGroup>
    <Folder Include="Properties\" />
    <Folder Include="Resources\" />
    <Folder Include="Resources\App Icons\" />
    <Folder Include="Resources\Launch Images\" />
  </ItemGroup>
  <ItemGroup>
    <Xib Include="LoginViewController~ipad.xib">
      <DependentUpon>LoginViewController.pas</DependentUpon>
    </Xib>
    <Xib Include="LoginViewController~iphone.xib">
      <DependentUpon>LoginViewController.pas</DependentUpon>
    </Xib>
  </ItemGroup>
  <Import Project="$(MSBuildExtensionsPath)\RemObjects Software\Oxygene\RemObjects.Oxygene.Nougat.targets" />
  <PropertyGroup>
    <PreBuildEvent />
  </PropertyGroup>
</Project>