# About

This bundle helps you to quickly inserts special character into your document. For this purpose the bundle currently adds a wide range of snippets and the command “Convert Single Character”.

# Snippets

Each of the snippets contained in this bundle inserts a single special character. The the tab triggers for the snippets are chosen according to one of the following two criteria.

1. If the special character looks similar to a sequence of – at least two – “normal” characters, then use these characters as tab trigger. For example: To insert the special character `⇒` just write down the characters `=>` and hit `⇥`.
2. If the first criterion does not apply then use the (shortened) name of the special character. For example: To insert the character `φ` – the small greek letter phi – use the tab trigger `phi`. To insert the capital letter phi (`Φ`) use the tab trigger `Phi`.

<center>
    <img src="Images/Triggers.gif" alt="Insert various special characters via tab trigger" style="width: 268px;"/>
</center>

# Convert Single Character

Like the name already suggest, this command converts the character to the left of the caret to another symbol. By default the command is bound to the key combination `ctrl` + `~`. Each time you press this key combination the character to the left of the character is replaced by another character. The mapping between the characters is cyclic. If you for example started with the character `o` and hit the key combination for the command multiple times, then the command eventually replaces the character on the left with the letter `o` again. The configuration file (`config.yaml`) handles which character is replaced by which other character. Lets take a look at the default configuration for the letter `o`:

    - oω◦ₒ # omega, white bullet, subscript o

The above line translates to the following mapping:

    o → ω
    ω → ◦
    ◦ → ₒ
    ₒ → o

This means that if you place the caret after one of the characters on the left and invoke the command, then it replaces the character with the one on the right. The design of the default mapping is similar to the one used by the snippets contained in this bundle:

1. If there is a standard character that looks similar to the special character, then you insert the special character by invoking the command (multiple times) after you placed the caret after the standard character. For example: To insert the character `₂` (subscript number 2) insert the number `2` and invoke the command once. If you press the key combination again, then the command replaces `₂` with the symbol `²` (superscript number 2).
2. If there exists no standard character that looks like the symbol, then just use the first letter of the symbol to insert it. For example to add the special character `θ` (small letter **t**heta) invoke the command after you pressed the key `t`. If you invoke the command again, then “Convert Single Character” replaces `θ` with the symbol `τ` (small letter **t**au).

<center>
    <img src="Images/Convert Single Character.gif" alt="Insert various special characters via “Convert Single Character”" style="width: 200px;"/>
</center>
