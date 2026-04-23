# VisualUefiEx

> **A streamlined environment setup and Visual Studio 2022 project template for developing UEFI applications and drivers using EDK-II.**

**VisualUefiEx** is based on the original **VisualUefi** project by **ionescu007**. While the original repository is a great foundation, configuring new projects often remains a tedious process. The default debugging commands are somewhat limited, and setting up the environment to seamlessly program in modern C++ is far from straightforward.

VisualUefiEx solves this by automating the tedious process of compiling the EDK-II BaseTools, setting up system environment variables, and installing a ready-to-use UEFI project template directly into Visual Studio. Furthermore, the provided template comes **pre-configured for C++ programming** right out of the box, and the integrated **debugger is fully functional independent of your project's name**.

## Prerequisites

Before installing, ensure you have the following installed on your system:

* **Git** (to clone the repository and its submodules).
* **Visual Studio 2022** with the **"Desktop development with C++"** workload (MSBuild is required).
* **NASM:** Required for assembly compilation. You must install NASM and create a system environment variable named `NASM_PREFIX` pointing to its installation directory. 
  > **⚠️ CRITICAL:** The `NASM_PREFIX` path **MUST** end with a trailing backslash (e.g., `C:\Path\To\Nasm\`).

## Installation

1. Clone the repository with the `--recursive` flag to fetch all submodules (including EDK-II):
```cmd
git clone https://github.com/link1nk/VisualUefiEx.git --recursive
```

2. Navigate to the cloned directory:
```cmd
cd VisualUefiEx
```

3. Run the setup script. You can simply double-click `Setup.bat` or run it via command line. 
*(Note: The script will automatically request Administrator privileges to set environment variables properly).*
```cmd
.\Setup.bat
```

### What `Setup.bat` does under the hood:
* Locates your Visual Studio 2022 MSBuild installation via `vswhere`.
* Compiles the EDK-II BaseTools (`EDK-II.sln`) for the x64 platform.
* Creates a persistent user environment variable (`VISUALUEFI_ROOT`) pointing to the project directory.
* Automatically copies the `UEFI Project.zip` template into your `Documents\Visual Studio 2022\Templates\ProjectTemplates` folder.

## Usage

1. After running the setup, **restart Visual Studio 2022** (if it was open) to refresh the template cache.
2. Click on **Create a new project**.
3. In the search bar, type **UEFI**.
4. Select the **UEFI Project** template and start writing your code!

## Troubleshooting

* **Visual Studio with MSBuild not found:** Make sure Visual Studio 2022 is installed correctly and the native C++ workloads are selected in the Visual Studio Installer.
* **Template not showing up:** Verify that the `UEFI Project.zip` was properly copied to your Documents folder. The setup script will warn you if it fails to find the Documents path.
