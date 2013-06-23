<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003" ToolsVersion="4.0">
  <PropertyGroup>
    <ProductVersion>3.5</ProductVersion>
    <ProjectGuid>{a963ae56-1b2b-4831-aa93-18a68a023c61}</ProjectGuid>
    <OutputType>Library</OutputType>
    <Platform Condition="'$(Platform)' == ''">Android</Platform>
    <Configuration Condition="'$(Configuration)' == ''">Release</Configuration>
    <AllowLegacyCreate>False</AllowLegacyCreate>
    <Name>Beta for Android</Name>
    <RootNamespace>com.remobjects.everwood.beta</RootNamespace>
    <AssemblyName>com.remobjects.beta</AssemblyName>
    <AndroidSDKPath />
    <AndroidPlatformName>
    </AndroidPlatformName>
    <DefaultUses>
    </DefaultUses>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Debug' ">
    <Optimize>False</Optimize>
    <OutputPath>bin\Debug\</OutputPath>
    <DefineConstants>DEBUG;TRACE</DefineConstants>
    <CaptureConsoleOutput>False</CaptureConsoleOutput>
    <StartMode>Project</StartMode>
    <RegisterForComInterop>False</RegisterForComInterop>
    <CpuType>anycpu</CpuType>
    <RuntimeVersion>v25</RuntimeVersion>
    <XmlDoc>False</XmlDoc>
    <XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
    <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
    <EnableUnmanagedDebugging>False</EnableUnmanagedDebugging>
    <JavaDigestAlgorith>SHA1</JavaDigestAlgorith>
    <JavaSignatureAlgorith>MD5withRSA</JavaSignatureAlgorith>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Release' ">
    <Optimize>true</Optimize>
    <OutputPath>.\bin\Release</OutputPath>
    <GenerateDebugInfo>False</GenerateDebugInfo>
    <EnableAsserts>False</EnableAsserts>
    <TreatWarningsAsErrors>False</TreatWarningsAsErrors>
    <CaptureConsoleOutput>False</CaptureConsoleOutput>
    <StartMode>Project</StartMode>
    <RegisterForComInterop>False</RegisterForComInterop>
    <CpuType>anycpu</CpuType>
    <RuntimeVersion>v25</RuntimeVersion>
    <XmlDoc>False</XmlDoc>
    <XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
    <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
    <EnableUnmanagedDebugging>False</EnableUnmanagedDebugging>
  </PropertyGroup>
  <ItemGroup>
    <Folder Include="Properties\" />
    <Folder Include="res\" />
    <Folder Include="res\drawable\" />
    <Folder Include="res\drawable-hdpi\" />
    <Folder Include="res\drawable-ldpi\" />
    <Folder Include="res\drawable-mdpi\" />
    <Folder Include="res\drawable-xhdpi\" />
    <Folder Include="res\layout\" />
    <Folder Include="res\menu\" />
    <Folder Include="res\layout-sw600dp" />
    <Folder Include="res\values\" />
    <Folder Include="res\values-v11\" />
    <Folder Include="res\values-v14\" />
    <Folder Include="res\xml\" />
  </ItemGroup>
  <ItemGroup>
    <Reference Include="android-support-v4.jar">
      <HintPath>libs\android-support-v4.jar</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="android.jar" />
    <Reference Include="com.remobjects.sdk.jar">
      <Private>True</Private>
    </Reference>
    <Reference Include="disklrucache-2.0.1.jar">
      <HintPath>libs\disklrucache-2.0.1.jar</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="gcm.jar">
      <HintPath>libs\gcm.jar</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="prettytime-3.0.2.Final.jar">
      <HintPath>libs\prettytime-3.0.2.Final.jar</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="webimageloader-1.2.0.jar">
      <HintPath>libs\webimageloader-1.2.0.jar</HintPath>
      <Private>True</Private>
    </Reference>
  </ItemGroup>
  <ItemGroup>
    <Compile Include="CommonUtilities.pas" />
    <Compile Include="DataAccess.pas" />
    <Compile Include="GCMIntentService.pas" />
    <Compile Include="LoginActivity.pas" />
    <Compile Include="PushProvider_Intf.pas" />
    <Compile Include="ServerUtilities.pas" />
    <Compile Include="ProductsListAdapter.pas" />
    <Compile Include="MainActivity.pas" />
  </ItemGroup>
  <ItemGroup>
    <AndroidManifest Include="Properties\AndroidManifest.xml">
      <SubType>Content</SubType>
    </AndroidManifest>
  </ItemGroup>
  <ItemGroup>
    <Content Include="res\drawable-hdpi\ic_launcher.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable-hdpi\ic_menu_add.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable-hdpi\ic_menu_load.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable-hdpi\ic_menu_settings.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable-hdpi\ic_menu_update.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable-hdpi\login_background.jpg">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable-hdpi\remobjects_logo.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable-ldpi\ic_launcher.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable-mdpi\ic_launcher.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable-mdpi\ic_menu_add.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable-mdpi\ic_menu_load.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable-mdpi\ic_menu_settings.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable-mdpi\ic_menu_update.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable-xhdpi\ic_launcher.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable-xhdpi\ic_menu_add.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable-xhdpi\ic_menu_load.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable-xhdpi\ic_menu_settings.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable-xhdpi\ic_menu_update.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable\empty_product_logo.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable\ic_launcher.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable\login_background.jpg">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable\new_version_badge.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\drawable\remobjects_logo.png">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\layout-sw600dp\activity_login.layout-xml">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\layout\activity_login.layout-xml">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\layout\activity_main.layout-xml">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\layout\activity_settings.layout-xml">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\layout\product_list_header.layout-xml">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\layout\product_list_item.layout-xml">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\menu\main.android-xml">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\values-v11\styles.android-xml">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\values-v14\styles.android-xml">
      <SubType>Content</SubType>
    </Content>
    <Content Include="res\values\styles.android-xml">
      <SubType>Content</SubType>
    </Content>
    <None Include="res\values\strings.android-xml">
      <SubType>Content</SubType>
    </None>
  </ItemGroup>
  <Import Project="$(MSBuildExtensionsPath)\RemObjects Software\Oxygene\RemObjects.Oxygene.Cooper.Android.targets" />
  <PropertyGroup>
    <PreBuildEvent />
  </PropertyGroup>
</Project>