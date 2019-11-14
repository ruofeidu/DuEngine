#include "DuConfig.h"
#include "DuUtils.h"
#include "stdafx.h"
using namespace std;

std::string DuConfig::DefaultName = "config.ini";

DuConfig::DuConfig() : DuConfig(DefaultName) {}

DuConfig::DuConfig(string filename) {
  m_bErrorIfNameNotFound = true;
  Load(filename);
  m_name = filename.substr(0, filename.size() - 4);
  if (!m_name.compare("config")) {
    m_name = "default";
  }
}

static string Trim(string str) {
  int first = 0;
  while (isspace(str[first])) first++;
  int last = (int)str.length() - 1;
  while (isspace(str[last])) last--;
  return str.substr(first, last - first + 1);
}

bool DuConfig::Load(string filename) {
  m_mEntries.clear();
  // Opens file.
  ifstream in(filename.c_str());
  if (!in.is_open()) {
    warning("Failed to open " + filename +
            ", using default parameters instead.");
    return false;
  }

  // Processes every line.
  char linebuf[1024];
  while (in.getline(linebuf, sizeof(linebuf))) {
    // '#' denotes a comment until the end of the line.
    if (strchr(linebuf, '#') != NULL) *strchr(linebuf, '#') = '\0';
    if (strchr(linebuf, ';') != NULL) *strchr(linebuf, ';') = '\0';

    string line = linebuf;
    // Gets name and value, separated by "=" symbol.
    size_t eq = line.find('=');
    if (eq != string::npos) {
      string name = line.substr(0, eq);
      string value = line.substr(eq + 1, string::npos);
      m_mEntries[Trim(name)] = Trim(value);
    }
  }

  return true;
}

vector<string> DuConfig::GetKeyList() const {
  vector<string> out(m_mEntries.size());
  auto oi = out.begin();
  for (auto it : m_mEntries) {
    *oi = it.first;
    ++oi;
  }
  return out;
}

string DuConfig::GetString(const string &name) const {
  map<string, string>::const_iterator iter = m_mEntries.find(name);
  if (iter == m_mEntries.end()) {
    if (m_bErrorIfNameNotFound) warning("Failed to lookup '" + name + "'.");
    return "";
  }
  return iter->second;
}

wstring DuConfig::GetWString(const string &name) const {
  string str = GetString(name);
  return std::wstring(str.begin(), str.end());
}

bool DuConfig::GetBool(const string &name) const {
  auto val = GetString(name);
  if (val == "t" || val == "T" || val == "Y" || val == "y" || val == "true" ||
      val == "yes" || val == "TRUE" || val == "YES")
    return true;
  return (atoi(GetString(name).c_str()) != 0);
}

int DuConfig::GetInt(const string &name) const {
  return atoi(GetString(name).c_str());
}

float DuConfig::GetFloat(const string &name) const {
  return (float)atof(GetString(name).c_str());
}

double DuConfig::GetDouble(const string &name) const {
  return atof(GetString(name).c_str());
}

std::string DuConfig::GetName() const { return m_name; }

bool DuConfig::HasKey(const string &name) const {
  return (m_mEntries.find(name) != m_mEntries.end());
}

string DuConfig::GetStringWithDefault(const string &name,
                                      const string &defaultValue) const {
  map<string, string>::const_iterator iter = m_mEntries.find(name);
  if (iter == m_mEntries.end()) {
    return defaultValue;
  }
  return iter->second;
}

wstring DuConfig::GetWStringWithDefault(const string &name,
                                        const wstring &defaultValue) const {
  string str = GetString(name);
  map<string, string>::const_iterator iter = m_mEntries.find(name);
  if (iter == m_mEntries.end()) {
    return defaultValue;
  }
  return std::wstring(iter->second.begin(), iter->second.end());
}

bool DuConfig::GetBoolWithDefault(const string &name,
                                  const bool defaultValue) const {
  auto iter = m_mEntries.find(name);
  return (iter == m_mEntries.end()) ? defaultValue : GetBool(name);
}

int DuConfig::GetIntWithDefault(const string &name,
                                const int defaultValue) const {
  auto iter = m_mEntries.find(name);
  return (iter == m_mEntries.end()) ? defaultValue : atoi(iter->second.c_str());
}

float DuConfig::GetFloatWithDefault(const string &name,
                                    const float defaultValue) const {
  auto iter = m_mEntries.find(name);
  return (iter == m_mEntries.end()) ? defaultValue
                                    : (float)atof(iter->second.c_str());
}

double DuConfig::GetDoubleWithDefault(const string &name,
                                      const double defaultValue) const {
  auto iter = m_mEntries.find(name);
  return (iter == m_mEntries.end()) ? defaultValue : atof(iter->second.c_str());
}
