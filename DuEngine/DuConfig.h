#pragma once
#include "stdafx.h"
#include <iostream>
#include <chrono>
#include <ctime>
#include <vector>

class DuConfig
{
public:
	static std::string DefaultName;
	std::string m_name; 

public:
	DuConfig();
	DuConfig(std::string filename);
	bool Load(std::string filename);

	void SetErrorIfNameNotFound(bool error) { m_bErrorIfNameNotFound = error; }

	std::string	GetString(const std::string &name) const;
	std::wstring GetWString(const std::string &name) const;
	bool GetBool(const std::string &name) const;
	int	GetInt(const std::string &name) const;
	float	GetFloat(const std::string &name) const;
	double GetDouble(const std::string &name) const;
	std::string GetName() const; 

public:
	std::vector<std::string> GetKeyList() const;
	bool HasKey(const std::string &name) const;

public:
	std::string	GetStringWithDefault(const std::string &name, const std::string& defaultValue) const;
	std::wstring GetWStringWithDefault(const std::string &name, const std::wstring& defaultValue) const;
	bool GetBoolWithDefault(const std::string &name, bool defaultValue) const;
	int	GetIntWithDefault(const std::string &name, int defaultValue) const;
	float	GetFloatWithDefault(const std::string &name, float defaultValue) const;
	double GetDoubleWithDefault(const std::string &name, double defaultValue) const;

protected:
	std::map<std::string, std::string> m_mEntries;
	bool m_bErrorIfNameNotFound;
};
