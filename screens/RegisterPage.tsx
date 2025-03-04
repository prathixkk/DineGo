import React, { useRef } from 'react';
import CustomButton from '../components/Button';
import { Stack } from '@rneui/layout';
import { View, ImageBackground, StyleSheet, TouchableHighlight, Alert } from 'react-native';
import { Text, Card, Image } from '@rneui/themed';
import Icon from 'react-native-vector-icons/MaterialIcons';

const RegisterPage = () => {
  return (
    <View style={styles.container}>
        <ImageBackground source={require('../assets/images/paneer.jpg')} style={styles.background}>
          <View style={styles.logoContainer}>
            <Image source={require('../assets/images/Logo.png')} style={styles.logo} />
          </View>
  
          <View>
            <Card containerStyle={styles.card}>
              <Card.Title>
                <Text style={{ fontFamily: 'Righteous-Regular', fontSize: 32, color:'#FAB12F' }}>Login</Text>
              </Card.Title>
              <Text style={{ fontFamily: 'RethinkSans-Regular', marginTop: 20, paddingLeft: 20 }}>
                Enter your Phone Number to Continue
              </Text>
  
              <View style={{ width: '100%', paddingTop: 10, alignItems: 'center' }}>
                <Stack row spacing={20} style={{ paddingTop: 10, alignItems: 'center', justifyContent: 'center' }}>
                  <CustomButton 
                    title="Login"
                    textColor="#FFFFFF"
                    backgroundColor="#FAB12F"
                    titleStyle={{ fontFamily: 'RethinkSans-ExtraBold', fontSize: 16, }}
                    buttonStyle={styles.buttons}
                  />
                  <CustomButton
                    title="Register"
                    textColor="#FFFFFF"
                    backgroundColor="#FAB12F"
                    titleStyle={{ fontFamily: 'RethinkSans-ExtraBold', fontSize: 16 }}
                    buttonStyle={styles.buttons}

                  />
                </Stack>
              </View>
  
              <Card.Divider style={{ paddingTop: 30 }} /> 
              <CustomButton
                icon={<Icon name="home" size={100}  />}
                title="Sign In With Google"
                textColor="#121212"
                backgroundColor="#ffffff"
                titleStyle={{ fontFamily: 'RethinkSans-Regular', fontSize: 14 }}
                buttonStyle={styles.googleButton}
              />
            </Card>
          </View>
  
        </ImageBackground>
        </View>
    );
  };
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
  export default RegisterPage;