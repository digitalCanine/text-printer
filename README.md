# digitalCanine's Text Printer

---

<https://github.com/user-attachments/assets/013bc8b9-3552-49c4-8af0-fda04889034b>

A small terminal script that prints a user-defined phrase in brackets, flooding the screen line by line with smoothly shifting colors.

## Usage

The provided text is always rendered in the form `[ TEXT ]`:

```bash
./printer.sh "DC"
./printer.sh "digitalCanine"
./printer.sh "github"
```

When no string is provided, the printer will default to printing `DC`.

## Color Modes

### Default Mode

Automatically uses a smooth gradient through the terminal's 256-color palette:

```bash
./printer.sh "Your Text"
```

### Rainbow Mode

Full truecolor rainbow gradient:

```bash
./printer.sh -r "Your Text"
./printer.sh --rainbow "Your Text"
```

### Pride Flag Mode

Display smooth gradients in pride flag colors:

```bash
./printer.sh --lgbt gay "Your Text"
./printer.sh --lgbt trans "Your Text"
```

#### Available Flags

- `gay` - Rainbow pride flag
- `trans` - Transgender pride flag
- `lesbian` - Lesbian pride flag
- `bi` - Bisexual pride flag
- `pan` - Pansexual pride flag
- `ace` - Asexual pride flag
- `aro` - Aromantic pride flag
- `nonbinary` / `enby` - Non-binary pride flag
- `genderfluid` - Genderfluid pride flag
- `agender` - Agender pride flag
- `poly` - Polyamorous pride flag
- `femboy` - Femboy pride flag

## Features

- **Smooth gradients**: Colors transition smoothly between lines instead of abrupt changes
- **Truecolor RGB support**: Pride flags use accurate RGB colors
- **Full terminal width**: Text fills the entire width of your terminal
- **Animated gradient**: Colors cycle and shift as new lines are printed

---

To exit the printer script, hit `ctrl+c`.

On exit, the terminal will print `The system stands, quietly`. You can always edit the script to customize this exit message.
