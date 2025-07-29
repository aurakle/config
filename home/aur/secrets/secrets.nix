let
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKxDrs0el9fGzyRvrZsa7e23SyXp8if2eO5ViAap8tYQ aur@eos";
in {
  "clickr-mine.age".publicKeys = [ user ];
  "clickr-evy.age".publicKeys = [ user ];
}
