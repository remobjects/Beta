<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003" ToolsVersion="4.0">
  <PropertyGroup>
    <RootNamespace>BetaServer</RootNamespace>
    <OutputType>Exe</OutputType>
    <AssemblyName>BetaServer</AssemblyName>
    <AllowGlobals>False</AllowGlobals>
    <AllowLegacyWith>False</AllowLegacyWith>
    <AllowLegacyCode>False</AllowLegacyCode>
    <AllowLegacyOutParams>True</AllowLegacyOutParams>
    <AllowUnsafeCode>False</AllowUnsafeCode>
    <ApplicationIcon>Properties\App.ico</ApplicationIcon>
    <Configuration Condition="'$(Configuration)' == ''">Release</Configuration>
    <TargetFrameworkVersion>v3.5</TargetFrameworkVersion>
    <Name>Beta Server</Name>
    <DefaultUses />
    <StartupClass />
    <InternalAssemblyName />
    <TargetFrameworkProfile />
    <ProjectGuid>{36699322-22f5-4fee-b484-653042f48fb8}</ProjectGuid>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Debug' ">
    <OutputPath>bin\Debug\</OutputPath>
    <DefineConstants>DEBUG;TRACE;</DefineConstants>
    <GeneratePDB>True</GeneratePDB>
    <CaptureConsoleOutput>False</CaptureConsoleOutput>
    <StartMode>Project</StartMode>
    <CpuType>anycpu</CpuType>
    <RuntimeVersion>v25</RuntimeVersion>
    <XmlDoc>False</XmlDoc>
    <XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
    <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'AdHoc' ">
    <DefineConstants>DEBUG;TRACE;</DefineConstants>
    <GeneratePDB>True</GeneratePDB>
    <CaptureConsoleOutput>False</CaptureConsoleOutput>
    <StartMode>Project</StartMode>
    <CpuType>anycpu</CpuType>
    <RuntimeVersion>v25</RuntimeVersion>
    <XmlDoc>False</XmlDoc>
    <XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
    <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
    <OutputPath>bin\AdHoc\</OutputPath>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Release' ">
    <OutputPath>.\bin\Release</OutputPath>
    <GeneratePDB>False</GeneratePDB>
    <GenerateMDB>False</GenerateMDB>
    <EnableAsserts>False</EnableAsserts>
    <TreatWarningsAsErrors>False</TreatWarningsAsErrors>
    <CaptureConsoleOutput>False</CaptureConsoleOutput>
    <StartMode>Project</StartMode>
    <RegisterForComInterop>False</RegisterForComInterop>
    <CpuType>anycpu</CpuType>
    <RuntimeVersion>v25</RuntimeVersion>
    <XmlDoc>False</XmlDoc>
    <XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
  </PropertyGroup>
  <ItemGroup>
    <Reference Include="Mono.Security">
      <Private>True</Private>
    </Reference>
    <Reference Include="mscorlib">
      <Name>mscorlib</Name>
    </Reference>
    <Reference Include="System">
      <Name>System</Name>
    </Reference>
    <Reference Include="RemObjects.SDK.ZLib">
      <HintPath>C:\Program Files (x86)\RemObjects Software\RemObjects SDK for .NET\Bin\RemObjects.SDK.ZLib.dll</HintPath>
      <Name>RemObjects.SDK.ZLib.dll</Name>
      <Private>True</Private>
    </Reference>
    <Reference Include="RemObjects.InternetPack">
      <HintPath>C:\Program Files (x86)\RemObjects Software\RemObjects SDK for .NET\Bin\RemObjects.InternetPack.dll</HintPath>
      <Name>RemObjects.InternetPack.dll</Name>
      <Private>True</Private>
    </Reference>
    <Reference Include="RemObjects.SDK">
      <HintPath>C:\Program Files (x86)\RemObjects Software\RemObjects SDK for .NET\Bin\RemObjects.SDK.dll</HintPath>
      <Name>RemObjects.SDK.dll</Name>
      <Private>True</Private>
    </Reference>
    <Reference Include="RemObjects.SDK.Server">
      <HintPath>C:\Program Files (x86)\RemObjects Software\RemObjects SDK for .NET\Bin\RemObjects.SDK.Server.dll</HintPath>
      <Name>RemObjects.SDK.Server.dll</Name>
      <Private>True</Private>
    </Reference>
    <Reference Include="System.Configuration.Install">
      <HintPath>C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.Configuration.Install.dll</HintPath>
    </Reference>
    <Reference Include="System.Drawing">
      <HintPath>C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.Drawing.dll</HintPath>
    </Reference>
    <Reference Include="System.ServiceModel">
      <HintPath>C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\v3.0\System.ServiceModel.dll</HintPath>
    </Reference>
    <Reference Include="System.ServiceProcess">
      <HintPath>C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.ServiceProcess.dll</HintPath>
    </Reference>
    <Reference Include="System.Windows.Forms">
      <HintPath>C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.Windows.Forms.dll</HintPath>
    </Reference>
    <Reference Include="System.Xml" />
    <Reference Include="System.Xml.Linq">
      <HintPath>C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\v3.5\System.Xml.Linq.dll</HintPath>
    </Reference>
  </ItemGroup>
  <ItemGroup>
    <Compile Include="BetaServer.pas" />
    <Compile Include="Engine.Designer.pas">
      <SubType>Component</SubType>
      <DesignableClassName>BetaServer.Engine</DesignableClassName>
    </Compile>
    <Compile Include="Engine.pas">
      <SubType>Component</SubType>
      <DesignableClassName>BetaServer.Engine</DesignableClassName>
    </Compile>
    <Compile Include="Log.pas" />
    <Compile Include="MainForm.Designer.pas">
      <SubType>Form</SubType>
      <DesignableClassName>BetaServer.MainForm</DesignableClassName>
    </Compile>
    <Compile Include="MainForm.pas">
      <SubType>Form</SubType>
      <DesignableClassName>BetaServer.MainForm</DesignableClassName>
    </Compile>
    <Compile Include="MainService.Designer.pas">
      <SubType>Component</SubType>
      <DesignableClassName>BetaServer.MainService</DesignableClassName>
    </Compile>
    <Compile Include="MainService.pas">
      <SubType>Component</SubType>
      <DesignableClassName>BetaServer.MainService</DesignableClassName>
    </Compile>
    <Compile Include="Notifier.pas" />
    <Compile Include="Main.pas" />
    <Compile Include="ProjectInstaller.Designer.pas">
      <SubType>Component</SubType>
      <DesignableClassName>Beta.ProjectInstaller</DesignableClassName>
    </Compile>
    <Compile Include="ProjectInstaller.pas">
      <SubType>Component</SubType>
      <DesignableClassName>Beta.ProjectInstaller</DesignableClassName>
    </Compile>
    <Compile Include="Properties\AssemblyInfo.pas" />
    <Compile Include="Properties\Settings.Designer.pas">
      <DependentUpon>Properties\Settings.settings</DependentUpon>
    </Compile>
    <Content Include="app.config">
      <SubType>Content</SubType>
    </Content>
    <Content Include="Properties\Settings.settings">
      <SubType>Content</SubType>
      <Generator>SettingsSingleFileGenerator</Generator>
    </Content>
    <EmbeddedResource Include="MainForm.resx">
      <DependentUpon>MainForm.pas</DependentUpon>
    </EmbeddedResource>
    <EmbeddedResource Include="Properties\licenses.licx" />
    <Content Include="BetaServer.iOS.p12">
      <SubType>Content</SubType>
      <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
    </Content>
    <Content Include="BetaServer.RODL">
      <SubType>Content</SubType>
    </Content>
    <Content Include="Properties\App.ico" />
    <None Include="Getting Started.html">
      <ExcludeFromBuild>Yes</ExcludeFromBuild>
    </None>
  </ItemGroup>
  <ItemGroup>
    <Folder Include="Properties\" />
  </ItemGroup>
  <ItemGroup>
    <ProjectReference Include="..\Push\RemObjects.SDK.Push\RemObjects.SDK.Push.oxygene">
      <Name>RemObjects.SDK.Push</Name>
      <Project>{6ee56252-1979-48fa-8409-3dced05426c3}</Project>
      <Private>True</Private>
      <HintPath>..\Push\RemObjects.SDK.Push\bin\Debug\RemObjects.SDK.Push.dll</HintPath>
    </ProjectReference>
  </ItemGroup>
  <Import Project="$(MSBuildExtensionsPath)\RemObjects Software\Oxygene\RemObjects.Oxygene.Echoes.targets" />
  <Import Project="$(MSBuildExtensionsPath)\RemObjects Software\RemObjects SDK\RemObjects.SDK.targets" />
  <PropertyGroup>
    <PreBuildEvent />
  </PropertyGroup>
</Project>