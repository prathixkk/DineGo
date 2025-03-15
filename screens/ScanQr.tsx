  import React, { useState, useEffect } from 'react';
import { Text, View, ImageBackground, Image, StyleSheet } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { ParamListBase } from '@react-navigation/native';
  
  
const ScanQr = () => {
  
    return (
  <View style={styles.container}>
      <ImageBackground source={require('../assets/images/paneer.jpg')} style={styles.background}>
        <View style={styles.logoContainer}>
          <Image source={require('../assets/images/Logo.png')} style={styles.logo} />
        </View>
        </ImageBackground>
    </View>
    );
}


const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  phoneNumberInputContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 20,
  },
  phoneNumberInput: {
    width: 270,
    height: 50,
    backgroundColor: '#ffffff',
    borderColor: '#e0e0e0',
    elevation: 0,
    borderWidth:1
  },
  card: {
    alignSelf: 'center',
    alignItems:'center',
    justifyContent:'center',
    width: 330,
    shadowColor: '#000000',
    shadowOffset: { width: 2, height: 40 },
    shadowOpacity: 100,
    shadowRadius: 20,
    elevation: 20,
    height: 350,
    maxWidth: '90%',
    borderRadius: 28,
  },
  googleButton: {
    marginTop: 0,
    alignSelf: 'center',
    paddingHorizontal: 40,
    width: 280,
    height: 45,
  },
  buttons: {
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
    width: 100,
    height: 40,
    borderRadius: 28,
    borderWidth: 0,
  },
  background: {
    flex: 1,
    width: '100%',
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },
  logoContainer: {
    alignItems: 'center',
    marginBottom: 0,
  },
  logo: {
    width: 200,
    height: 200,
    resizeMode: 'contain',
  },
});

export default ScanQr;