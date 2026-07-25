#!/usr/bin/env python3
"""Generate Velanera.xcodeproj/project.pbxproj from the source tree."""

from __future__ import annotations

import hashlib
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = ROOT / "Velanera"
PROJECT_PATH = ROOT / "Velanera.xcodeproj" / "project.pbxproj"


def oid(name: str) -> str:
    digest = hashlib.md5(name.encode("utf-8")).hexdigest()[:24].upper()
    return digest


def rel(path: Path) -> str:
    return str(path.relative_to(ROOT)).replace("\\", "/")


swift_files = sorted(SOURCE_ROOT.rglob("*.swift"))
asset_catalogs = sorted(SOURCE_ROOT.rglob("*.xcassets"))
plist_file = SOURCE_ROOT / "Info.plist"
entitlements = SOURCE_ROOT / "Velanera.entitlements"

file_refs: dict[str, tuple[str, str, str]] = {}
build_files: list[str] = []

for path in swift_files:
    key = rel(path)
    ref = oid(f"fileref:{key}")
    build = oid(f"build:{key}")
    file_refs[key] = (ref, build, path.name)
    build_files.append(f"\t\t{build} /* {path.name} in Sources */ = {{isa = PBXBuildFile; fileRef = {ref} /* {path.name} */; }};")

resources: list[str] = []
for path in asset_catalogs:
    key = rel(path)
    ref = oid(f"fileref:{key}")
    build = oid(f"build:{key}")
    file_refs[key] = (ref, build, path.name)
    resources.append(f"\t\t{build} /* {path.name} in Resources */ = {{isa = PBXBuildFile; fileRef = {ref} /* {path.name} */; }};")

plist_ref = oid("fileref:Info.plist")
entitlements_ref = oid("fileref:entitlements")
file_refs[rel(plist_file)] = (plist_ref, "", "Info.plist")
file_refs[rel(entitlements)] = (entitlements_ref, "", "Velanera.entitlements")

# Group hierarchy under Velanera/
group_children: dict[str, list[str]] = {}
group_ids: dict[str, str] = {"": oid("group:Velanera")}

for key, (ref, _, name) in file_refs.items():
    # key like Velanera/Theme/Foo.swift
    parts = Path(key).parts
    assert parts[0] == "Velanera"
    parent = ""
    for part in parts[1:-1]:
        child_path = f"{parent}/{part}" if parent else part
        if child_path not in group_ids:
            group_ids[child_path] = oid(f"group:{child_path}")
            group_children.setdefault(parent, [])
            entry = f"{group_ids[child_path]} /* {part} */"
            if entry not in group_children[parent]:
                group_children[parent].append(entry)
        parent = child_path
    group_children.setdefault(parent, []).append(f"{ref} /* {name} */")

project_id = oid("project")
target_id = oid("target")
sources_phase = oid("sources")
resources_phase = oid("resources")
frameworks_phase = oid("frameworks")
project_group = oid("group:root")
products_group = oid("group:products")
config_group = oid("group:config")
product_ref = oid("product:Velanera.app")
debug_conf = oid("conf:debug")
release_conf = oid("conf:release")
project_debug = oid("projconf:debug")
project_release = oid("projconf:release")
target_configs = oid("targetconfigs")
project_configs = oid("projectconfigs")

file_ref_entries = []
for key, (ref, _, name) in sorted(file_refs.items()):
    if key.endswith(".xcassets"):
        ftype = "folder.assetcatalog"
    elif key.endswith(".plist"):
        ftype = "text.plist.xml"
    elif key.endswith(".entitlements"):
        ftype = "text.plist.entitlements"
    else:
        ftype = "sourcecode.swift"
    file_ref_entries.append(
        f"\t\t{ref} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = {ftype}; path = {name}; sourceTree = \"<group>\"; }};"
    )
file_ref_entries.append(
    f"\t\t{product_ref} /* Velanera.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Velanera.app; sourceTree = BUILT_PRODUCTS_DIR; }};"
)

# Config file refs
debug_xcconfig = ROOT / "Config" / "Debug.xcconfig"
release_xcconfig = ROOT / "Config" / "Release.xcconfig"
debug_xc_ref = oid("fileref:Debug.xcconfig")
release_xc_ref = oid("fileref:Release.xcconfig")
file_ref_entries.append(
    f"\t\t{debug_xc_ref} /* Debug.xcconfig */ = {{isa = PBXFileReference; lastKnownFileType = text.xcconfig; path = Debug.xcconfig; sourceTree = \"<group>\"; }};"
)
file_ref_entries.append(
    f"\t\t{release_xc_ref} /* Release.xcconfig */ = {{isa = PBXFileReference; lastKnownFileType = text.xcconfig; path = Release.xcconfig; sourceTree = \"<group>\"; }};"
)

group_entries = []
for path, gid in sorted(group_ids.items(), key=lambda x: x[0]):
    name = Path(path).name if path else "Velanera"
    children = "\n".join(f"\t\t\t\t{child};" for child in sorted(set(group_children.get(path, []))))
    path_line = "\n\t\t\tpath = Velanera;" if path == "" else f"\n\t\t\tpath = {name};"
    group_entries.append(
        f"\t\t{gid} /* {name} */ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n{children}\n\t\t\t);{path_line}\n\t\t\tsourceTree = \"<group>\";\n\t\t}};"
    )

group_entries.append(
    f"""\t\t{config_group} /* Config */ = {{
			isa = PBXGroup;
			children = (
				{debug_xc_ref} /* Debug.xcconfig */,
				{release_xc_ref} /* Release.xcconfig */,
			);
			path = Config;
			sourceTree = "<group>";
		}};"""
)

group_entries.append(
    f"""\t\t{products_group} /* Products */ = {{
			isa = PBXGroup;
			children = (
				{product_ref} /* Velanera.app */,
			);
			name = Products;
			sourceTree = "<group>";
		}};"""
)

group_entries.append(
    f"""\t\t{project_group} = {{
			isa = PBXGroup;
			children = (
				{group_ids['']} /* Velanera */,
				{config_group} /* Config */,
				{products_group} /* Products */,
			);
			sourceTree = "<group>";
		}};"""
)

sources_list = "\n".join(
    f"\t\t\t\t{file_refs[rel(path)][1]} /* {path.name} in Sources */,"
    for path in swift_files
)
resources_list = "\n".join(
    f"\t\t\t\t{file_refs[rel(path)][1]} /* {path.name} in Resources */,"
    for path in asset_catalogs
)

pbx = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 56;
	objects = {{

/* Begin PBXBuildFile section */
{chr(10).join(build_files)}
{chr(10).join(resources)}
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{chr(10).join(file_ref_entries)}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		{frameworks_phase} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
{chr(10).join(group_entries)}
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		{target_id} /* Velanera */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {target_configs} /* Build configuration list for PBXNativeTarget "Velanera" */;
			buildPhases = (
				{sources_phase} /* Sources */,
				{frameworks_phase} /* Frameworks */,
				{resources_phase} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = Velanera;
			productName = Velanera;
			productReference = {product_ref} /* Velanera.app */;
			productType = "com.apple.product-type.application";
		}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		{project_id} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1600;
				LastUpgradeCheck = 1600;
				TargetAttributes = {{
					{target_id} = {{
						CreatedOnToolsVersion = 16.0;
					}};
				}};
			}};
			buildConfigurationList = {project_configs} /* Build configuration list for PBXProject "Velanera" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = {project_group};
			productRefGroup = {products_group} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{target_id} /* Velanera */,
			);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		{resources_phase} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{resources_list}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		{sources_phase} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{sources_list}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		{project_debug} /* Debug */ = {{
			isa = XCBuildConfiguration;
			baseConfigurationReference = {debug_xc_ref} /* Debug.xcconfig */;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_TESTABILITY = YES;
				GCC_DYNAMIC_NO_PIC = NO;
				IPHONEOS_DEPLOYMENT_TARGET = 18.0;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			}};
			name = Debug;
		}};
		{project_release} /* Release */ = {{
			isa = XCBuildConfiguration;
			baseConfigurationReference = {release_xc_ref} /* Release.xcconfig */;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				IPHONEOS_DEPLOYMENT_TARGET = 18.0;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				VALIDATE_PRODUCT = YES;
			}};
			name = Release;
		}};
		{debug_conf} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = Velanera/Velanera.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Velanera/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = Velanera;
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.food-and-drink";
				IPHONEOS_DEPLOYMENT_TARGET = 18.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = co.velanera.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Debug;
		}};
		{release_conf} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = Velanera/Velanera.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Velanera/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = Velanera;
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.food-and-drink";
				IPHONEOS_DEPLOYMENT_TARGET = 18.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = co.velanera.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Release;
		}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		{project_configs} /* Build configuration list for PBXProject "Velanera" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{project_debug} /* Debug */,
				{project_release} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{target_configs} /* Build configuration list for PBXNativeTarget "Velanera" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{debug_conf} /* Debug */,
				{release_conf} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList section */
	}};
	rootObject = {project_id} /* Project object */;
}}
"""

PROJECT_PATH.parent.mkdir(parents=True, exist_ok=True)
PROJECT_PATH.write_text(pbx)


# Shared scheme
scheme_dir = ROOT / "Velanera.xcodeproj" / "xcshareddata" / "xcschemes"
scheme_dir.mkdir(parents=True, exist_ok=True)
scheme_path = scheme_dir / "Velanera.xcscheme"
scheme_path.write_text(f"""<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<Scheme
   LastUpgradeVersion = \"1600\"
   version = \"1.7\">
   <BuildAction
      parallelizeBuildables = \"YES\"
      buildImplicitDependencies = \"YES\">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = \"YES\"
            buildForRunning = \"YES\"
            buildForProfiling = \"YES\"
            buildForArchiving = \"YES\"
            buildForAnalyzing = \"YES\">
            <BuildableReference
               BuildableIdentifier = \"primary\"
               BlueprintIdentifier = \"{target_id}\"
               BuildableName = \"Velanera.app\"
               BlueprintName = \"Velanera\"
               ReferencedContainer = \"container:Velanera.xcodeproj\">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = \"Debug\"
      selectedDebuggerIdentifier = \"Xcode.DebuggerFoundation.Debugger.LLDB\"
      selectedLauncherIdentifier = \"Xcode.DebuggerFoundation.Launcher.LLDB\"
      shouldUseLaunchSchemeArgsEnv = \"YES\"
      shouldAutocreateTestPlan = \"YES\">
   </TestAction>
   <LaunchAction
      buildConfiguration = \"Debug\"
      selectedDebuggerIdentifier = \"Xcode.DebuggerFoundation.Debugger.LLDB\"
      selectedLauncherIdentifier = \"Xcode.DebuggerFoundation.Launcher.LLDB\"
      launchStyle = \"0\"
      useCustomWorkingDirectory = \"NO\"
      ignoresPersistentStateOnLaunch = \"NO\"
      debugServiceExtension = \"internal\"
      allowLocationSimulation = \"YES\">
      <BuildableProductRunnable
         runnableDebuggingMode = \"0\">
         <BuildableReference
            BuildableIdentifier = \"primary\"
            BlueprintIdentifier = \"{target_id}\"
            BuildableName = \"Velanera.app\"
            BlueprintName = \"Velanera\"
            ReferencedContainer = \"container:Velanera.xcodeproj\">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = \"Release\"
      shouldUseLaunchSchemeArgsEnv = \"YES\"
      savedToolIdentifier = \"\"
      useCustomWorkingDirectory = \"NO\"
      debugDocumentVersioning = \"YES\"
      askForAppToLaunch = \"Yes\">
      <BuildableProductRunnable
         runnableDebuggingMode = \"0\">
         <BuildableReference
            BuildableIdentifier = \"primary\"
            BlueprintIdentifier = \"{target_id}\"
            BuildableName = \"Velanera.app\"
            BlueprintName = \"Velanera\"
            ReferencedContainer = \"container:Velanera.xcodeproj\">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = \"Debug\">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = \"Release\"
      revealArchiveInOrganizer = \"YES\">
   </ArchiveAction>
</Scheme>
""")
print(f"Wrote {scheme_path}")

print(f"Wrote {PROJECT_PATH}")
print(f"Swift files: {len(swift_files)}")
print(f"Asset catalogs: {len(asset_catalogs)}")
