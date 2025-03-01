// CustomButton.tsx
import * as React from "react";
import { ReactNode } from "react";
import { Button } from "@rneui/themed";
import { Icon } from "@rneui/base";

interface CustomButtonProps {
  title: string;
  onPress?: () => void;
  backgroundColor?: string;
  textColor?: string;
  width?: number;
  height?: number;
  disabled?: boolean;
  titleStyle?: object;       // from your interface
  buttonStyle?: object;      // from your interface
  size?: "small" | "medium" | "large";
  icon?:object; // add IconComponent to the interface
}

const CustomButton: React.FC<CustomButtonProps> = ({
  title,
  onPress,
  backgroundColor = "#11111",
  textColor = "#111111",
  width = 150,
  height = 50,             // you can add a default for height, too
  disabled = false,
  buttonStyle, // destructure from props
  titleStyle   // destructure from props
}) => {
  return (
    <Button
      buttonStyle={[
        {
          width,
          height,
          borderRadius: 28,
          backgroundColor,
          borderColor: '#121212',
            borderWidth: 1,
            justifyContent: "center",
            alignItems: "center",
           
        },
        buttonStyle, // merge user‐provided buttonStyle last, so it overrides
      ]}
      titleStyle={[
        {
          marginHorizontal: 5,
          fontFamily: "Rethink-Sans",
          fontSize: 18,
          fontWeight: "regular",
          color: textColor,
          alignItems: "center",
          justifyContent: "center"
        },
        titleStyle, // merge user‐provided titleStyle last
      ]}
      onPress={onPress}
      disabled={disabled}
    >
      {title}
    </Button>
  );
};

export default CustomButton;
