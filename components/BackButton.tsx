import React from 'react';
import { TouchableOpacity, Text, StyleSheet } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Icon from 'react-native-vector-icons/MaterialIcons';

const BackButton = () => {
  const navigation = useNavigation(); // Get navigation instance

  return (
    <TouchableOpacity style={styles.button} onPress={() => navigation.goBack()}>
      <Icon name="arrow-back-ios" size={30} color="white" /> 
      <Text style={styles.text}> Back</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 10,
  },
  text: {
    fontFamily: 'Arial',
    fontSize: 20,
    color: 'white',
  },
});

export default BackButton;