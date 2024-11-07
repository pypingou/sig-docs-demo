Name:           auto-apps
Version:        0.1
Release:        1%{?dist}
Summary:        A test RPM of auto-apps

License:        MIT
Source0:        auto-apps-%{version}.tar.gz

BuildRequires:  cmake make gcc-c++ boost-devel vsomeip3-devel

%description
Sample auto applications

%prep
%autosetup

%build
%cmake
%cmake_build

%install
%cmake_install

%files
%{_bindir}/engine-service
%{_bindir}/radio-client
%{_bindir}/radio-service

%changelog
* Tue Feb 20 2024 your_name <your_email>
- Initial packaging
