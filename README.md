# Interactive iptables Viewer

A **Bash script** to explore `iptables` rules interactively in the terminal with color-coded targets.

---

## Features

- Browse **iptables** tables and chains interactively
- View rules with **colored targets**:
  - **ACCEPT** → green
  - **DROP** / **REJECT** → red
  - Others → yellow
- Navigate back using **ESC**:

---

## Requirements

- Linux with `iptables`
- `fzf` for interactive selection

```bash
sudo apt install fzf
```
---

## Installation

### 1. Save the script locally:

```bash
git clone https://github.com/davitgasoyan/iptables-view
cd iptables-view
chmod +x iptables-view.sh
```

### 2. Run with root privileges:

```bash
sudo ./iptables-view.sh
``` 

---

## Usage

### 1. Select a table (**filter**, **nat**, **mangle**, etc.)

### 2. Select a chain (**INPUT**, **FORWARD**, **OUTPUT**, etc.)

### 3. Browse rules with arrow buttons:

```bash
Default policy: DROP
---------------------------------------------------------------
tcp    any                any                22     ACCEPT
tcp    any                any                80     ACCEPT
any    any                any                -      DROP
```

### 4. Use ESC to go back:

---

## Notes

* Read-only: does not modify iptables
* Lightweight and fast, parses `iptables-save` output
* Ideal for inspection and lab environments
